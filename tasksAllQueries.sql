--1: fetch all paitings that are not displayed by museums

select W.name, W.museum_id
from dbo.work W left outer join dbo.museum M on W.museum_id = M.museum_id
where W.museum_id IS NULL

--2: are there museums without any paintings?

select M.name, COUNT(W.name) AS num_of_works
from dbo.museum M
full outer join dbo.work W ON M.museum_id = W.museum_id
group by M.name
having count(W.name) = 0;

--3: how many paintings have an asking price bigger than their regular price?

select count(*) as total
from dbo.product_size
where sale_price > regular_price

--4: identify paintings whose asking price is less 50% than regular price

select W.name, P.sale_price, P.regular_price
from dbo.product_size P inner join dbo.work W on P.work_id = W.work_id
where sale_price < (0.5 * regular_price)

--5: which canva size costs the most?

 select P.size_id, AVG(sale_price) as avg_price
 from dbo.product_size P inner join dbo.work W on P.work_id = W.work_id
 group by size_id
 order by AVG(sale_price) desc

--6: delete duplicate rows from dbo.work

with CTE as (
    select work_id, row_number() over (partition by name, artist_id, style order by work_id) as duplicateCount
    from dbo.work
    )
delete W
from work W
join CTE C on W.work_id = C.work_id
where C.duplicateCount > 1

--7: identify museums with invalid city information

select *
from museum
where city LIKE '%[0-9]%' or state is null;

--9: 10 most fameous painting subjects

select top 10 S.subject, count(W.name) num_of_works
from subject S join work W on S.work_id = W.work_id
group by S.subject
order by count(W.name) desc

--10: identify museums opened on both monday and sunday

select M.name 
from museum_hours H left join museum M on H.museum_id = M.museum_id
where day in ('Monday', 'Sunday')
group by M.name
having count(day) = 2
order by M.name

--11: which museums are opened every single day?

select M.name 
from museum_hours H left join museum M on H.museum_id = M.museum_id
group by M.name
having count(day) = 7
order by M.name

--12: which are the most popluar museums? (museums with most num of paintings) : top 5

select top 5 M.name, count(W.name) as num_of_works
from dbo.museum M inner join dbo.work W on M.museum_id = W.museum_id
group by M.name
order by count(W.name) desc

--13: who are the artists with the biggest numbers of pieces created?

select top 10 full_name, count(name) num_of_pieces_created
from artist A join work W on A.artist_id = W.artist_id
group by full_name
order by count(name) desc

--14: least popular canvas sizes

 select size_id, MAX(x.num_of_pieces) num_of_pieces from (
 select W.work_id, size_id,ROW_NUMBER() over(partition by size_id order by W.work_id) as num_of_pieces
 from product_size P join work W on P.work_id = W.work_id
 ) x
group by size_id 
order by num_of_pieces

--16: which museum has most pieces of the most popular style of painting?

select top 1 m.name, w.style, count(*) as num_of_paint
from museum m
JOIN work w
on m.museum_id = w.museum_id
group by m.name, w.style
order by count(*) desc

--17: identify artists whose paintings are displayed in multiple countries

select x.full_name, MAX(num_of_countries) num_of_countries from (
select A.full_name, W.name painting, M.name, M.country, dense_rank() over(partition by A.full_name order by M.Country) as num_of_countries
from artist A 
    join work W on W.artist_id = A.artist_id 
    join museum M on M.museum_id = W.museum_id
    ) x
    where x.num_of_countries > 1
    group by x.full_name
    order by num_of_countries desc

--or
    
select A.full_name, count(distinct M.country) as num_of_countries
from artist A
join work W on W.artist_id = A.artist_id
join museum M on M.museum_id = W.museum_id
group by A.full_name
having count(distinct M.country) > 1
order by num_of_countries desc

--18: display country with the biggest number of museums

select count(distinct name) num_of_museums, country
from museum
group by country

--19: identify the museum with the cheapest and most expensive painting

select M.name AS museum_name, W.name AS painting_name, P.regular_price, P.sale_price
from museum M
join work W on M.museum_id = W.museum_id
join product_size P on P.work_id = W.work_id
where P.sale_price = (select(sale_price) from product_size) 
   or P.sale_price = (select max(sale_price) from product_size);

--20: which country has the 4th highest number of paintings?

with countryRank as (
select count(distinct W.name) num_paintings, country, row_number() over(order by count(distinct W.name) desc) as ranking
from work W join museum M on W.museum_id = M.museum_id
group by country
)
select country, num_paintings
from countryRank
where ranking = 4