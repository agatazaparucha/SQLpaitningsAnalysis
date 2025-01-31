
# SQL Portfolio Project: Famous Paintings Analysis

This project showcases my SQL skills by analyzing a dataset of famous paintings from Kaggle. The dataset includes information about paintings, museums, artists, and more. Below, I have outlined the SQL queries I wrote to extract meaningful insights from the data. The most complex queries are described in detail.

---

## Dataset Source
The dataset used in this project is available on Kaggle:  
[Famous Paintings Dataset](https://www.kaggle.com/datasets/mexwell/famous-paintings)

---

## Database Setup
I used Microsoft SQL Server to create and manage the databases for this project. Initially, I experimented with importing the data using a Python script; however, due to my university's security measures, this approach proved unfeasible. Instead, I utilized SQL Server's Import Wizard to create tables directly from the CSV files downloaded from Kaggle. This method ensured a smooth and efficient import process, allowing me to focus on writing and optimizing SQL queries.

## Queries

### 1. **Fetch all paintings that are not displayed by museums**
```sql
SELECT W.name, W.museum_id
FROM dbo.work W 
LEFT OUTER JOIN dbo.museum M ON W.museum_id = M.museum_id
WHERE W.museum_id IS NULL;
```
**Description**: This query identifies paintings that are not associated with any museum. It uses a `LEFT OUTER JOIN` to combine the `work` and `museum` tables and filters rows where the `museum_id` is `NULL`.

---

### 2. **Are there museums without any paintings?**
```sql
SELECT M.name, COUNT(W.name) AS num_of_works
FROM dbo.museum M
FULL OUTER JOIN dbo.work W ON M.museum_id = W.museum_id
GROUP BY M.name
HAVING COUNT(W.name) = 0;
```
**Description**: This query checks if there are museums that do not have any paintings. It uses a `FULL OUTER JOIN` to ensure all museums are included, even if they have no associated paintings, and filters using `HAVING COUNT(W.name) = 0`.

---

### 3. **How many paintings have an asking price bigger than their regular price?**
```sql
SELECT COUNT(*) AS total
FROM dbo.product_size
WHERE sale_price > regular_price;
```
**Description**: This query calculates the number of paintings where the sale price is higher than the regular price. It uses a simple `WHERE` clause to filter the `product_size` table.

---

### 4. **Identify paintings whose asking price is less than 50% of the regular price**
```sql
SELECT W.name, P.sale_price, P.regular_price
FROM dbo.product_size P 
INNER JOIN dbo.work W ON P.work_id = W.work_id
WHERE sale_price < (0.5 * regular_price);
```

---

### 5. **Which canvas size costs the most?**
```sql
SELECT P.size_id, AVG(sale_price) AS avg_price
FROM dbo.product_size P 
INNER JOIN dbo.work W ON P.work_id = W.work_id
GROUP BY size_id
ORDER BY AVG(sale_price) DESC;
```

---

### 6. **Delete duplicate rows from `dbo.work`**
```sql
WITH CTE AS (
    SELECT work_id, ROW_NUMBER() OVER (PARTITION BY name, artist_id, style ORDER BY work_id) AS duplicateCount
    FROM dbo.work
)
DELETE W
FROM work W
JOIN CTE C ON W.work_id = C.work_id
WHERE C.duplicateCount > 1;
```
**Description**: This query removes duplicate rows from the dbo.work table. It uses a `Common Table Expression (CTE)` with the `ROW_NUMBER()` function to identify duplicates based on the combination of `name, artist_id, and style`. Rows with a `duplicateCount` greater than 1 are deleted, ensuring only unique records remain.

---

### 7. **Identify museums with invalid city information**
```sql
SELECT *
FROM museum
WHERE city LIKE '%[0-9]%' OR state IS NULL;
```

---

### 8. **10 most famous painting subjects**
```sql
SELECT TOP 10 S.subject, COUNT(W.name) AS num_of_works
FROM subject S 
JOIN work W ON S.work_id = W.work_id
GROUP BY S.subject
ORDER BY COUNT(W.name) DESC;
```

---

### 9. **Identify museums opened on both Monday and Sunday**
```sql
SELECT M.name 
FROM museum_hours H 
LEFT JOIN museum M ON H.museum_id = M.museum_id
WHERE day IN ('Monday', 'Sunday')
GROUP BY M.name
HAVING COUNT(day) = 2
ORDER BY M.name;
```
**Description**: This query joins the `museum_hours` table with the `museum` table to get museum names, filters for rows where the day is either `Monday` or `Sunday`, and groups the results by `museum name`. The `HAVING COUNT(day) = 2` ensures only museums open on both days are included. Finally, the results are ordered alphabetically by museum name.

---

### 10. **Which museums are opened every single day?**
```sql
SELECT M.name 
FROM museum_hours H 
LEFT JOIN museum M ON H.museum_id = M.museum_id
GROUP BY M.name
HAVING COUNT(day) = 7
ORDER BY M.name;
```

---

### 11. **Most popular museums (top 5 by number of paintings)**
```sql
SELECT TOP 5 M.name, COUNT(W.name) AS num_of_works
FROM dbo.museum M 
INNER JOIN dbo.work W ON M.museum_id = W.museum_id
GROUP BY M.name
ORDER BY COUNT(W.name) DESC;
```

---

### 12. **Artists with the most pieces created (top 10)**
```sql
SELECT TOP 10 full_name, COUNT(name) AS num_of_pieces_created
FROM artist A 
JOIN work W ON A.artist_id = W.artist_id
GROUP BY full_name
ORDER BY COUNT(name) DESC;
```

---

### 13. **Least popular canvas sizes**
```sql
SELECT size_id, MAX(x.num_of_pieces) AS num_of_pieces 
FROM (
    SELECT W.work_id, size_id, ROW_NUMBER() OVER (PARTITION BY size_id ORDER BY W.work_id) AS num_of_pieces
    FROM product_size P 
    JOIN work W ON P.work_id = W.work_id
) x
GROUP BY size_id 
ORDER BY num_of_pieces;
```
**Description**: This query identifies the least popular canvas sizes based on the number of paintings associated with each size. It uses a subquery with the `ROW_NUMBER()` function to assign a unique count `(num_of_pieces)` to each canvas size `(size_id)`. The outer query groups the results by `size_id` and selects the maximum count for each size. Finally, the results are ordered by `num_of_pieces` to show the least popular sizes first.

---

### 14. **Museum with the most pieces of the most popular painting style**
```sql
SELECT TOP 1 m.name, w.style, COUNT(*) AS num_of_paint
FROM museum m
JOIN work w ON m.museum_id = w.museum_id
GROUP BY m.name, w.style
ORDER BY COUNT(*) DESC;
```

---

### 15. **Artists whose paintings are displayed in multiple countries**
```sql
SELECT A.full_name, COUNT(DISTINCT M.country) AS num_of_countries
FROM artist A
JOIN work W ON W.artist_id = A.artist_id
JOIN museum M ON M.museum_id = W.museum_id
GROUP BY A.full_name
HAVING COUNT(DISTINCT M.country) > 1
ORDER BY num_of_countries DESC;
```
**Description**: This query identifies artists whose paintings are displayed in multiple countries. It joins the `artist, work, and museum` tables to associate artists with the countries where their paintings are displayed. The `COUNT(DISTINCT M.country)` calculates the number of unique countries for each artist. The `HAVING COUNT(DISTINCT M.country) > 1 `filters the results to include only artists with paintings in more than one country. Finally, the results are ordered in descending order by the number of countries, showing the artists with the most international presence first.
---

### 16. **Country with the biggest number of museums**
```sql
SELECT COUNT(DISTINCT name) AS num_of_museums, country
FROM museum
GROUP BY country;
```

---

### 17. **Museum with the cheapest and most expensive painting**
```sql
SELECT M.name AS museum_name, W.name AS painting_name, P.regular_price, P.sale_price
FROM museum M
JOIN work W ON M.museum_id = W.museum_id
JOIN product_size P ON P.work_id = W.work_id
WHERE P.sale_price = (SELECT MIN(sale_price) FROM product_size) 
   OR P.sale_price = (SELECT MAX(sale_price) FROM product_size);
```

---

### 18. **Country with the 4th highest number of paintings**
```sql
WITH countryRank AS (
    SELECT COUNT(DISTINCT W.name) AS num_paintings, country, 
           ROW_NUMBER() OVER (ORDER BY COUNT(DISTINCT W.name) DESC) AS ranking
    FROM work W 
    JOIN museum M ON W.museum_id = M.museum_id
    GROUP BY country
)
SELECT country, num_paintings
FROM countryRank
WHERE ranking = 4;
```

---

## Conclusion
This project demonstrates my ability to write complex SQL queries to analyze and manipulate data. The queries range from simple filtering to advanced aggregations and subqueries, showcasing a strong understanding of SQL concepts.
