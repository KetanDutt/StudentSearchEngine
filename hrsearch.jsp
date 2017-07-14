<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Search</title>
<link rel="stylesheet" href="css/bootstrap.css">
<link rel="icon" href="images/logo.ico" />
</head>
<body style="background-color:#FFAE00">
<nav class="navbar navbar-default">
<div class="container-fluid"> 
<div class="navbar-header">
<button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#bs-example-navbar-collapse-1" aria-expanded="false"> <span class="sr-only">Toggle navigation</span> <span class="icon-bar"></span> <span class="icon-bar"></span> <span class="icon-bar"></span> </button>
<a class="navbar-brand">FindinG</a> </div>
<div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
<ul class="nav navbar-nav">
<li><a href="index.html">SignIn<span class="sr-only">(current)</span></a> </li>
<li><a href="register.html">SignUp</a> </li>
</ul>
<ul class="nav navbar-nav navbar-right">
<li class="dropdown"> <a class="dropdown-toggle" data-toggle="dropdown" role="button" aria-expanded="false" aria-haspopup="true">About<span class="caret"></span></a>
<ul class="dropdown-menu">
<li><a>Developed Bye :- </a></li>
<li><a>KeTan Dutt </a></li>
<li><a>B.tech PIET (IT)</a></li>
<li role="separator" class="divider"></li>
<li><a>For DRDO</a> </li>
</ul>
</li>
</ul>
</div>
</div>
</nav>


<header>
<div align="center">
<div class="jumbotron2">
<div class="container2">
<h1 class="text-center" style=" font-size:50px">FindinG</h1>
<p class="text-center">Job Search</p> <br><br>

<table class="table table-hover table-bordered" >
<thead>
<tr>
<th>Name</th>
<th>Company</th>
<th>No. Of Employees</th>
<th>Heighest Salary</th>
<th>Product for</th>
<th>Company</th>
<th>Product for</th>
<th>Company</th>
<th>Job in</th>
<th>Job Type</th>
<th>Salary</th>
<th>Job in</th>
<th>Job Type</th>
<th>Salary</th>
</tr>
</thead>


<%@ page import="java.sql.*"%>
<%@ page import="javax.sql.*"%>
<%try{
String search=request.getParameter("search"); 
session.putValue("usr",search);
String user;
String cid; 
String auth; 
String yr;
String emp;
String hsal;
String t1;
String t2;
String c1;
String c2;
String jid;
String jt;
String js;
String jid2;
String jt2;
String js2;
Class.forName("com.mysql.jdbc.Driver"); 
java.sql.Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/project","root","toor"); 
Statement st= con.createStatement(); 
ResultSet rs=st.executeQuery("select * from company where user like '%"+search+"%' or cid like '%"+search+"%'"
+ " or auth like '%"+search+"%' or yr like '%"+search+"%' or emp like '%"+search+"%' or hsal like "
+ "'%"+search+"%' or brch like '%"+search+"%' or addr like '%"+search+"%' or t1 like '%"+search+"%' or t2 like "
+ "'%"+search+"%' or c1 like '%"+search+"%' or c2 like '%"+search+"%' or a1 like '%"+search+"%' or a2 "
+ "like '%"+search+"%' or y1 like '%"+search+"%' or y2 like '%"+search+"%' or jid like '%"+search+"%' or ja like "
+ "'%"+search+"%' or jt like '%"+search+"%' or js like '%"+search+"%' or jid2 like '%"+search+"%' or ja2 like '%"+search+"%'"
+ " or jt2 like '%"+search+"%' or js2 like '%"+search+"%'"); 

while(rs.next()){ 

user  = rs.getString(1);
cid = rs.getString(2);
auth = rs.getString(3);
yr = rs.getString(4);
emp  = rs.getString(5);
hsal = rs.getString(6);
t1 = rs.getString(9);
t2 = rs.getString(13);
c1  = rs.getString(10);
c2 = rs.getString(14);
jid = rs.getString(17);
jt = rs.getString(19);
js = rs.getString(20);
jid2 = rs.getString(21);
jt2 = rs.getString(23);
js2 = rs.getString(24);

%><td><%
out.print(user);
%></td><td><%
out.print(cid);
%></td><td><%
out.print(emp);
%></td><td><%
out.print(hsal);
%></td><td><%
out.print(t1);
%></td><td><%
out.print(c1);
%></td><td><%
out.print(t2);
%></td><td><%
out.print(c2);
%></td><td><%
out.print(jid);
%></td><td><%
out.print(jt);
%></td><td><%
out.print(js);
%></td><td><%
out.print(jid2);
%></td><td><%
out.print(jt2);
%></td><td><%
out.print(js2);
%></td></tr><%

}
}
catch(Exception e){ out.println(e.getMessage()); }
%>
</table>
</div>
</div>
</div>
</header>
</body>
</html>