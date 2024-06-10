PYTHON


# %s is a variable that points to the passed parameter; the '\' in the SQL statement is used to create a line break

def getProductOrdersByType(db_conn, prod_type):
    cursor = db_conn.cursor()
    sql_string = "SELECT po.*  \
            FROM product_orders po  \
            INNER JOIN products p  \
            ON po.product_id = p.product_id  \
            WHERE p.product_type = %s"
    cursor.execute(sql_string, [prod_type])
    return cursor.fetchall()


Option 1: Filter for quantity > 3
def getProductOrdersByType(db_conn, prod_type):
    cursor = db_conn.cursor()
    sql_string = "SELECT po.*  \
            FROM product_orders po  \
            INNER JOIN products p  \
            ON po.product_id = p.product_id  \
            WHERE p.product_type = %s  \
            AND quantity > 3"
    cursor.execute(sql_string, [prod_type])
    return cursor.fetchall()

all_fryers = getProductOrdersByType(conn, 'fryer')


Option 2: Substitute the literal '3' for a parameter for quantity
def getProductOrdersByType(db_conn, prod_type):
    cursor = db_conn.cursor()
    sql_string = "SELECT po.*  \
            FROM product_orders po  \
            INNER JOIN products p  \
            ON po.product_id = p.product_id  \
            WHERE p.product_type = %s  \
            AND quantity > %s"
    cursor.execute(sql_string, [prod_type,3])
    return cursor.fetchall()

all_fryers = getProductOrdersByType(conn, 'fryer')