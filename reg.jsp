<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
</head>
<body>
<%@ page import ="java.sql.*" %>
<%@ page import ="javax.sql.*" %>
<%try{
String user=request.getParameter("userid"); 
session.putValue("userid",user); 
String pwd=request.getParameter("pwd"); 
String fname=request.getParameter("fname"); 
String lname=request.getParameter("lname"); 
String email=request.getParameter("email");
String occ=request.getParameter("occ");
Class.forName("com.mysql.jdbc.Driver"); 
java.sql.Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/project",
"root","toor"); 
Statement st= con.createStatement(); 
ResultSet rs; 
int i=st.executeUpdate("insert into user values ('"+user+"','"+pwd+"','"+fname+"','"+lname+"','"+email+"','"+occ+"')"); 
}catch(Exception e)
{ out.println(e.getMessage());
}
%>
<script type="text/javascript" >
alert("Registered");
window.open("index.html","_self");
</script>
</body>
</html>