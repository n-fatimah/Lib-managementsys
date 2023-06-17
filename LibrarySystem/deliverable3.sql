-- group 12 procedures


USE master 
go
drop database LibMS 
go
create database LibMS
go
use LibMS 
go


create table SignUp_ ------------------done
(
   studentid char(7)  primary key not null,
   Firstname varchar(100) not null,
   lastname varchar(100) ,
   email varchar(100)  not null,
   password_ varchar(100) unique not null ,
   confirm_password varchar(100) not null,
  --(studentid,password_)
)


--create table category_ -------------------------done
--(
-- Categoryid int not null ,
-- categoryname varchar(100) unique ,
-- book_you_might_like varchar(100),

-- primary key(categoryid)
--)

create table category_   ------------------done
(
 Categoryid int not null ,
 categoryname varchar(100) ,
 --book_you_might_like varchar(100),

 primary key(categoryid)
)
INSERT INTO category_ 
values(5,'horror'),
(1,'IDONTKNOw')
select* from category_



insert into category_ values (5,'history','The Independence and colonialism')

create table BookListvisibility_   ------------------done
(
  Bookid char(4) primary key not null , 
  title varchar(100) unique,
  author varchar(100),
  categoryid int foreign key references category_(categoryid ),
  availability_ int check (availability_ =1 or availability_ =0) -- 0 for not available 1 for  available

)

--insert into BookListvisibility_ 
--values(5,'FINAL DESTINANTION','IDONTKNOW',5,1),
--(1,'GOD OF FLIES','IDONTKNOW',1,0)

--select * from BookListvisibility_

create table staff -----------------------done
(
Staffid char(7) primary key not null,
firstname varchar(100) ,
lastname varchar(100),
email varchar(100),
password_ varchar(100) unique not null,
categoryid_ int foreign key references category_(categoryid)

)


create table login_students-------------------------done
(
  Studentid char(7) foreign key references signup_(studentid)  not null,
  password_ varchar(100) foreign key references signup_(password_)  not null,
  primary key (studentid)

)

create table login_staff --------------------------done
(
  staffid char(7) foreign key references staff(Staffid) not null ,
 
  password_ varchar(100) foreign key references staff(password_) not null,
  primary key (staffid)
)


create table Issue_and_return_date_visibility --------------------------done
(
Studentid char(7) foreign key references signup_(studentid) ,
bookid char(4) foreign key references BookListvisibility_(bookid) not null ,
issuedate date unique not null,
returndate date,
primary key(bookid,issuedate)
)



create table accounts -----------------------done
(

Studentid char(7) foreign key references signup_(studentid) not null,
Bookid char(4) foreign key references BookListvisibility_(bookid) not null,
issuedate date foreign key references Issue_and_return_date_visibility(issuedate) not null,
returnstatus int check (returnstatus =1 or returnstatus =0), -- 0 for late 1 for  on time
due_returndate date,
returned_on date, 
fine_amount int, 
fine_staus varchar(7), -- clear paid pending

 primary key(studentid,bookid,issuedate)
)



create table blacklisted_students -------------------------done
(
  studentid char(7) foreign key references signup_(studentid) not null,
  statuss varchar(11) ,               --blacklisted

  primary key(studentid)

)

create table Reviews ----------------------------done
(

bookid char(4) foreign key references BookListvisibility_(bookid) not null,
 title varchar(100) foreign key references BookListvisibility_(title) , 
 categoryname varchar(100) foreign key references category_(categoryname)  ,
 reviews float check(reviews >=0 or reviews <=5),
 noOfIssues int  ,

 primary key(bookid)

)


-- stored procedures

--drop procedure psignup

create PROCEDURE psignup (@stid char(7) ,@fname varchar(100),@lname varchar(100),@emaill varchar(100),@pass varchar(100),@cpass varchar(100))


AS
BEGIN
if(@cpass=@pass)  
begin

insert into [SignUp_] values (@stid,@fname,@lname,@emaill,@pass,@cpass)
print '--successfully signed up '
end
else 
begin
print '--Enter password again carefully'
end
end
go
exec [psignup] 'l202133','fatima','Muneer','l202133@lhr.nu.edu.pk','p123_','p123_'

--exec [psignup] 'l200999','Noor','Fatimah','l200999@lhr.nu.edu.pk','n123_','p123_'

--2


create PROCEDURE pstudent_login (@stid char(7) ,@pass varchar(100))
AS
BEGIN
declare @saved_pass varchar(100)
set @saved_pass= (select password_ from signup_ where studentid=@stid)
if(@saved_pass=@pass)  
begin
print '--successfully logged in '
end
else 
begin
print '--Enter password again carefully -- LOGIN UNSUCCESSFUL--'
end
end
go
exec pstudent_login 'l202133','p123_'
exec pstudent_login 'l202133','p13_'

--

create PROCEDURE pstaff (@stid char(7) ,@fname varchar(100),@lname varchar(100),@emaill varchar(100),@pass varchar(100),@catid varchar(100))
AS
BEGIN  
insert into staff values (@stid,@fname,@lname,@emaill,@pass,@catid)
print '-- data recorded successfully--- '
end
go
exec pstaff 'stl151a','Saad','Faisal','stl151a@lhr.nu.edu.pk','shutup_',5 -- 5 is the id of history 


--
--drop table category


alter PROCEDURE pcategory (
@catid char(7) ,@catname varchar(100))
AS
BEGIN 
declare @books_uliikevarchar varchar (100) 
declare @bool int
declare @cttype varchar (100)
set @cttype=
(select c.categoryname
from category_ as c
where c.categoryid=@catid)

set @bool=
(select b.availability_
from BookListvisibility_ as b
where b.categoryid=@catid)

set @books_uliikevarchar=
(select b.title
from BookListvisibility_ as b
where b.categoryid=@catid)
--insert into staff values (@catid,@catname,@books_uliikevarchar)
if (@bool=1)
begin
print '-----------------------'
print 'this category'
print @@cttype
print 'includes'
print @books_uliikevarchar
print ' book availabe'
print '-----------------------'
end
else 
begin
print @books_uliikevarchar
print 'Not availabe'

end
end
go

exec pcategory 5,'horror' -- 5 is the id of history 
exec pcategory 1,'IDONTKNOW'

--


create PROCEDURE pstaff_login (@stid char(7) ,@pass varchar(100))
AS
BEGIN
declare @saved_pass varchar(100)
set @saved_pass= (select password_ from staff where Staffid=@stid)
if(@saved_pass=@pass)  
begin
print '--successfully logged in '
end
else 
begin
print '--Enter password again carefully -- LOGIN UNSUCCESSFUL--'
end
end
go
exec pstaff_login 'stl151a','shutup_'

--

--drop procedure p_BookListvisibility_
create procedure p_BookListvisibility_(@bookid char(4), @title varchar(100) ,@author varchar(100),@catid int )
as begin

declare @cid int
set @cid =-1
set @cid=(select categoryid from category_ where categoryid=@catid)
if(@cid!=-1)
begin
declare @availability_ int 
set @availability_=1
insert into BookListvisibility_ values (@bookid,@title,@author,@catid,@availability_)
print '-- book info inserted -- '
end
else 
begin
print '-- invalid entry -- book info not inserted  '

end
end
go
exec p_BookListvisibility_ 'h124','colonialism','anonymous',5
exec p_BookListvisibility_ 'h124','colonialism','anonymous',-2
--

create procedure IR_visibility (@Studentid char(7) ,@bookid char(4),@issuedate date output,@retdate date output)
as begin
declare @sid char(7) , @bid char(4) 
set @sid=-1
set @bid=-1
set @sid=(select studentid from SignUp_ where studentid=@studentid)
set @bid=(select bookid from BookListvisibility_ where bookid=@bookid)

if((@sid!=-1 )and (@bid!=-1 ))
begin
set @issuedate=(select issuedate from Issue_and_return_date_visibility where Studentid=@studentid and bookid=@bookid )
set @retdate=(select returndate from Issue_and_return_date_visibility where Studentid=@studentid and bookid=@bookid )
print '--returned the issued and return date ---'
end
else 
begin
print '--data entered is invalid  ---'

end
end 
go
declare @i_date date, @r_date date
exec IR_visibility 'l202097','h124',@i_date output,@r_date output
--



-- show if student has due fine or not 
go
create procedure p_accounts(@Studentid char(7) ,@fine_am int output,@fine_st varchar(7) output)
as begin
declare @sid char(7)
set @sid=-1

set @sid=(select studentid from SignUp_ where studentid=@studentid)
if(@sid!=-1)
begin
set @fine_am=(select fine_amount from accounts where Studentid=@studentid)
set @fine_st=(select fine_staus from accounts where Studentid=@studentid)
print '--Student fine record ---'

end
else 
begin
print '--data entered is invalid  ---'

end
end
go
declare @famount int, @fstatus varchar(7)
exec p_accounts 'l202097',@famount output,@fstatus output

--
--drop  procedure p_blacklisted_students
go
create procedure p_blacklisted_students(@studentid char(7),@st varchar(11) output)
as 
begin
declare @sid char(7) 
set @sid=-1

set @sid=(select studentid from SignUp_ where studentid=@studentid)
if(@sid!=-1)
begin
set @sid=-2 
set @sid=(select studentid from blacklisted_students where studentid=@studentid)
if(@sid!=-2)
begin
set @st=(select statuss from blacklisted_students where Studentid=@sid)
print '--Student is blacklisted---'
end
else if(@sid=-2)
begin
print '--Student is not blacklisted---'
end
end
else
begin
print '--data entered is invalid  ---'
end
end
go
declare @status varchar(11)
exec p_blacklisted_students 'l202097',@status  output
--


create procedure p_Reviews (@title varchar(100),@r float output ,@issueno int output)
as begin
declare @t varchar(100)
set @t=-1
set @t=(select title from BookListvisibility_ where title = @title)
if(@t!=-1)
begin
set @r=(select reviews from Reviews where title=@title )
set @issueno=(select noOfIssues from Reviews where title=@title )
print '---Reviews printed---'
end 
else 
begin
print '--data entered is invalid  ---'
end
end
go
declare @rev float,@noof_issues int
exec p_Reviews 'h431',@rev  output,@noof_issues output