# --- GIAI ĐOẠN 1: BUILD ---
# Dùng Maven và JDK 17 (Tương thích tốt nhất với Jakarta EE 10)
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app

# 1. Copy pom.xml trước
COPY pom.xml .

# 2. Tải trước các thư viện (Dependency) để lưu vào Cache của Docker
# Bước này giúp các lần build sau cực nhanh nếu bạn chỉ sửa code mà không sửa thư viện
RUN mvn dependency:go-offline

# 3. Copy toàn bộ source code vào
COPY src ./src

# 4. Build ra file .war (Bỏ qua test để tránh lỗi môi trường khi build)
RUN mvn clean package -DskipTests

# --- GIAI ĐOẠN 2: RUN ---
# Dùng Tomcat 10.1 (Bắt buộc cho Jakarta EE 10)
FROM tomcat:10.1-jdk17

# 1. Xóa các ứng dụng mặc định của Tomcat cho sạch sẽ
RUN rm -rf /usr/local/tomcat/webapps/*

# 2. Copy file .war từ giai đoạn Build vào thư mục webapps
# Lưu ý: Dùng *.war để Docker tự tìm file bất kể tên là 'db-1.0.war' hay 'db-SNAPSHOT.war'
# Đổi tên thành ROOT.war -> Để khi chạy web sẽ vào thẳng trang chủ (không cần gõ /db phía sau)
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

# 3. Mở cổng 8080
EXPOSE 8080

# 4. Chạy Tomcat
CMD ["catalina.sh", "run"]