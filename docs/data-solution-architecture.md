# Data Solution Architecture — E-commerce Analytics

Kiến trúc ELT hiện có trong repository: dlt nạp dữ liệu từ SQL Server vào DuckDB; dbt biến đổi dữ liệu theo các lớp; Dagster điều phối ingestion và transformation.

```mermaid
flowchart LR
    SQL[("SQL Server<br/>schema: e_commerce<br/>customer · ecom_sales<br/>product · region")]
    DLT["dlt ingestion<br/>SQL database source<br/>Full refresh: replace"]

    subgraph DUCK["DuckDB — warehouse.duckdb"]
        direction LR
        RAW[("Raw<br/>4 bảng nguồn")]
        STG["Staging · 5 views<br/>Chuẩn hóa tên cột<br/>Tạo lịch ngày"]
        INT["Intermediate · 2 views<br/>Bổ sung product / region<br/>bị thiếu bằng Unknown"]
        DW[("Warehouse · 5 tables<br/>dim_customer · dim_product<br/>dim_region · dim_date<br/>fct_ecom_sales")]
        MART[("Data marts · 15 tables<br/>Doanh thu · Lợi nhuận · Chiết khấu<br/>RFM · Churn risk · Cross-sell")]
        RAW --> STG
        STG --> INT
        INT --> DW
        STG --> DW
        DW --> MART
    end

    SQL --> DLT --> RAW
    MART -. "Kết nối BI cần xác nhận" .-> BI["Power BI<br/>report/report.pbix"]

    subgraph ORCH["Dagster — orchestration"]
        direction TB
        SCH["Schedule<br/>07:00 ngày 1 hằng tháng<br/>Asia/Ho_Chi_Minh"]
        ING["ingestion_job"]
        SENSOR["Success sensor<br/>run_dbt_after_ingestion"]
        TRANS["transformation_job<br/>dbt build"]
        SCH --> ING --> SENSOR --> TRANS
    end

    ING -. "Chạy ingestion" .-> DLT
    TRANS -. "Build models và chạy tests" .-> STG
    TRANS -. "Build" .-> INT
    TRANS -. "Build" .-> DW
    TRANS -. "Build" .-> MART

    classDef source fill:#e0f2fe,stroke:#0284c7,color:#0c4a6e
    classDef storage fill:#dcfce7,stroke:#16a34a,color:#14532d
    classDef transform fill:#fff7ed,stroke:#ea580c,color:#7c2d12
    classDef control fill:#f3e8ff,stroke:#9333ea,color:#581c87
    class SQL,BI source
    class RAW,DW,MART storage
    class DLT,STG,INT transform
    class SCH,ING,SENSOR,TRANS control
```

Mũi tên liền thể hiện luồng dữ liệu hoặc trình tự điều phối trong nhóm Dagster. Mũi tên nét đứt thể hiện lệnh điều phối; riêng đường tới Power BI là kết nối chưa được xác nhận.

## Các thành phần

| Thành phần | Vai trò | Mã nguồn / artifact |
|---|---|---|
| SQL Server | Nguồn dữ liệu `e_commerce`: customer, ecom_sales, product, region | `dbt_model/models/staging/sources.yml`, `ingestion/load_data.py` |
| dlt | Đọc nguồn SQL và nạp lại toàn bộ 4 bảng vào dataset `raw` | `ingestion/load_data.py` |
| DuckDB | Lưu raw và các lớp dữ liệu dbt trong cùng một database; đường dẫn qua `DUCKDB_PATH` | `dbt_model/profiles.yml` |
| dbt staging | 5 views: customer, product, region, sales và lịch ngày được sinh từ dbt_date | `dbt_model/models/staging/` |
| dbt intermediate | 2 views bổ sung bản ghi Unknown cho product / region xuất hiện trong sales nhưng thiếu ở nguồn dimension | `dbt_model/models/intermediate/` |
| dbt warehouse | Star schema gồm 4 dimensions và 1 fact; dimensions sử dụng surrogate keys | `dbt_model/models/warehouse/` |
| dbt marts | 15 bảng phân tích phục vụ các câu hỏi kinh doanh | `dbt_model/models/marts/` |
| Dagster | Lịch ingestion, theo dõi trạng thái thành công và kích hoạt `dbt build` | `orchestration/` |
| Power BI | File báo cáo hiện có; chưa xác nhận nguồn và chế độ refresh của báo cáo | `report/report.pbix` |

## Ví dụ lineage: chiết khấu trung bình theo category

```mermaid
flowchart LR
    RS["raw.ecom_sales"] --> SS["stg_ecom_sales"] --> F["fct_ecom_sales"]
    RP["raw.product"] --> SP["stg_product"] --> IP["int_product"] --> DP["dim_product"]
    SS --> IP
    DP --> F
    OTHER["dim_customer<br/>dim_region<br/>dim_date"] --> F
    F --> Q["q05_avg_discount_by_category<br/>AVG(discount) × 100<br/>GROUP BY category"]
    DP --> Q
```

## Ghi chú triển khai

- Đây là batch full refresh: ingestion dùng `write_disposition='replace'`; chưa có cơ chế incremental hoặc CDC trong mã nguồn đã kiểm tra.
- Lịch được khai báo chạy lúc 07:00 ngày 1 mỗi tháng theo giờ Việt Nam. Việc chạy tự động cần schedule, sensor và Dagster daemon được bật trong môi trường triển khai.
- `dbt build` thực thi models và các tests đã khai báo như `not_null`, `unique`, `relationships`.
- Staging và intermediate được materialize thành views; warehouse và marts thành tables. Tên schema vật lý phụ thuộc quy tắc generate schema của dbt; với cấu hình mặc định và target `main`, tên thường là `main_staging`, `main_intermediate`, `main_warehouse`, `main_marts`.
- Lịch ngày hiện sinh từ `2020-01-01` tới `2024-01-01`; fact sử dụng inner joins với dimensions nên độ phủ khóa và ngày ảnh hưởng đến số dòng được giữ lại.
- Sơ đồ mô tả kiến trúc từ mã nguồn, chưa xác minh một deployment đang chạy hoặc kết nối thực tế bên trong file Power BI.
