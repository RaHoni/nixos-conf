#!/usr/bin/env nix-shell
#! nix-shell -i bash -p mariadb

# MySQL user credentials
MYSQL_USER="root" # Using the root user for MySQL

# Directory where the dumps will be saved
BACKUP_DIR="/mysqlbackups"

# Path to the MySQL Unix socket
MYSQL_SOCKET="/run/mysqld/mysqld.sock"

# Create the backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Get a list of all databases
databases=$(mysql -u "$MYSQL_USER" --socket="$MYSQL_SOCKET" -e "SHOW DATABASES;" | tr -d "| " | grep -v Database)

# Loop through each database and export it to a separate file
for db in $databases; do
    if [[ "$db" != "information_schema" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "mysql" ]] && [[ "$db" != "sys" ]]; then
        echo "Exporting database: $db"
        mysqldump -u "$MYSQL_USER" --socket="$MYSQL_SOCKET" --databases "$db" > "$BACKUP_DIR/$db.sql"
    fi
done

# Export users and their permissions
echo "Exporting users and permissions"
mysqldump -u "$MYSQL_USER" --socket="$MYSQL_SOCKET" mysql > "$BACKUP_DIR/mysql_users_and_permissions.sql"

echo "All databases and users have been exported successfully."
