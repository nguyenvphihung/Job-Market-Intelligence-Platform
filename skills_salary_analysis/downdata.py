import psycopg2
import pandas as pd

# Thông tin kết nối Supabase
conn = psycopg2.connect(
    host="aws-0-ap-southeast-1.pooler.supabase.com",
    port=5432,
    dbname="postgres",
    user="postgres.zplfdsvrcudykpuwahms",
    password="hungjsgxsw6",
    sslmode='require'  # Supabase yêu cầu SSL
)

# Đọc dữ liệu bảng jobs
df = pd.read_sql_query("SELECT * FROM jobs", conn)

df.to_csv("jobs_data.csv", index=False)


# Hiển thị 5 dòng đầu
print(df.head())

# Đóng kết nối
conn.close()

