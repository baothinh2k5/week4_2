# --- GIAI ĐOẠN 1: BUILD (Sử dụng Maven để đóng gói) ---
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app

# Copy file cấu hình và source code vào container
COPY pom.xml .
COPY src ./src

# Chạy lệnh build (tạo file .war trong thư mục target)
# Dùng -DskipTests để build nhanh hơn và tránh lỗi test vặt trên server
RUN mvn clean package -DskipTests

# --- GIAI ĐOẠN 2: RUN (Sử dụng Tomcat 10 để chạy) ---
FROM tomcat:10.1-jdk17

# Xóa các ứng dụng mặc định của Tomcat để nhẹ và sạch
RUN rm -rf /usr/local/tomcat/webapps/*

# --- [QUAN TRỌNG] ---
# Copy file .war từ giai đoạn build vào thư mục webapps của Tomcat
# Dùng *.war để chấp nhận mọi tên file (dù có version hay không)
# Đổi tên thành ROOT.war để truy cập trực tiếp qua đường dẫn gốc
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

# Mở port 8080 (Mặc định của Tomcat)
EXPOSE 8080

# Lệnh khởi động Server
CMD ["catalina.sh", "run"]