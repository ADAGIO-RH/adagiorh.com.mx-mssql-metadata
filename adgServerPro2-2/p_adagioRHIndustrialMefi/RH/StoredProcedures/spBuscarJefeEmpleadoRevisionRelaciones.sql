USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [RH].[spBuscarJefeEmpleadoRevisionRelaciones] --0, 72, 1281,1
(    
  @IDJefeEmpleado int = 0    
 ,@IDEmpleado int      
 ,@IDJefe int     
 ,@IDUsuario int    
) as    
 Declare @IDUsuarioTrabajando int    
   ,@NombreCompletoTrabajando varchar(255)    
   ,@NombreCompletoJefe varchar(255)    
   ,@MessageError varchar(255)  
   ;    
    
  select Top 1 @NombreCompletoTrabajando = NombreCompleto from RH.tblEmpleadosMaster where IDEmpleado = @IDEmpleado    
  select Top 1 @NombreCompletoJefe = NombreCompleto from RH.tblEmpleadosMaster where IDEmpleado = @IDJefe    
 Select @IDUsuarioTrabajando = IDUsuario from Seguridad.tblUsuarios where IDEmpleado = @IDJefe    

 if object_id('tempdb..#tempEmpleadosRelaciones') is not null drop table #tempEmpleadosRelaciones;              
              
 create table #tempEmpleadosRelaciones (  
   IDJefe int  
  ,IDEmpleado int  
  ,Mensaje Varchar(255)
 ) 


  
 if (@IDJefe = @IDEmpleado)
 BEGIN
	insert into #tempEmpleadosRelaciones
	select @IDJefe, @IDEmpleado, 'Empleado Jefe no pueden ser la misma persona'
 END    
  
  
if object_id('tempdb..#tempEmpleadosSubordinados') is not null drop table #tempEmpleadosSubordinados;              
              
 create table #tempEmpleadosSubordinados (  
  IDJefe int  
  ,IDEmpleado int  
 )    
  
 ;With CteSubordinados    
 As    
 (    
  select fe.IDJefe,fe.IDEmpleado, cast(fe.IDJefe as varchar(MAX)) +' -> '+ cast(fe.IDEmpleado as varchar(max)) as [Path]   
  from RH.tblJefesEmpleados fe  
   join [Seguridad].[TblUsuarios] u on u.IDEmpleado = fe.IDEmpleado  
  where fe.IDJefe = @IDEmpleado and fe.IDEmpleado not in (Select IDEmpleado from #tempEmpleadosSubordinados)            
  Union All    
  select fe.IDJefe,fe.IDEmpleado, CAST(cast(P.[Path] as varchar(max))+' -> '+ cast(fe.IDEmpleado as varchar(max)) AS varchar(max)) AS [path]  
  from RH.tblJefesEmpleados fe  
  Inner Join CteSubordinados P On fe.IDJefe = p.IDEmpleado  
   join [Seguridad].[TblUsuarios] u on u.IDEmpleado = p.IDEmpleado  
  where  fe.IDEmpleado not in (Select IDEmpleado from #tempEmpleadosSubordinados)      
   and fe.IDJefe <>  @IDEmpleado      
   and  fe.IDJefe <> fe.IDEmpleado  
 )   
   
 insert into #tempEmpleadosSubordinados(IDJefe,IDEmpleado)            
 select cte.IDJefe,cte.IDEmpleado--,cte.Path, ROW_NUMBER()OVER(Partition by cte.IDJefe,cte.IDEmpleado order by CTE.IDEmpleado ) repetir  
 from CteSubordinados cte  
  join RH.tblEmpleadosMaster e on cte.IDEmpleado = e.IDEmpleado  
 order by cte.Path, ROW_NUMBER()OVER(Partition by cte.IDJefe,cte.IDEmpleado order by CTE.IDEmpleado )  
 OPTION (MAXRECURSION 0); 
 
 --select * from #tempEmpleadosSubordinados 
  
  if object_id('tempdb..#tempEmpleadosJefes') is not null drop table #tempEmpleadosJefes;              
              
 create table #tempEmpleadosJefes (  
  IDJefe int  
  ,IDEmpleado int  
 )  
  
 ;With CteJefes    
 As    
 (    
  select fe.IDJefe,fe.IDEmpleado, cast(fe.IDJefe as varchar(MAX)) +' -> '+ cast(fe.IDEmpleado as varchar(max)) as [Path]  
  from RH.tblJefesEmpleados fe  
   join [Seguridad].[TblUsuarios] u on u.IDEmpleado = fe.IDEmpleado  
  where fe.IDEmpleado = @IDJefe and fe.IDEmpleado not in (Select IDEmpleado from #tempEmpleadosJefes)            
  Union All    
  select fe.IDJefe,fe.IDEmpleado, CAST(cast(P.[Path] as varchar(max))+' -> '+ cast(fe.IDEmpleado as varchar(max)) AS varchar(max)) AS [path]   
  from RH.tblJefesEmpleados fe  
  Inner Join CteJefes P On fe.IDJefe = p.IDEmpleado  
   join [Seguridad].[TblUsuarios] u on u.IDEmpleado = p.IDEmpleado  
  where  fe.IDJefe not in (Select IDEmpleado from #tempEmpleadosJefes)            
   and fe.IDEmpleado <>  @IDJefe      
   and  fe.IDEmpleado <> fe.IDEmpleado  
 )  
  
 insert into #tempEmpleadosJefes(IDJefe,IDEmpleado)    
 select cte.IDJefe,cte.IDEmpleado--,cte.Path, ROW_NUMBER()OVER(Partition by cte.IDJefe,cte.IDEmpleado order by CTE.IDEmpleado ) repetir  
 from CteJefes cte  
  join RH.tblEmpleadosMaster e on cte.IDEmpleado = e.IDEmpleado  
 order by cte.Path, ROW_NUMBER()OVER(Partition by cte.IDJefe,cte.IDEmpleado order by CTE.IDEmpleado )  
 OPTION (MAXRECURSION 0);   
 
 --select * from #tempEmpleadosJefes 

  
if ((select top 1 1 from #tempEmpleadosJefes where IDJefe = @IDJefe and IDEmpleado = @IDEmpleado) = 1 
		OR  (select top 1 1 from #tempEmpleadosSubordinados where IDJefe = @IDEmpleado and IDEmpleado = @IDJefe ) = 1 )
		
BEGIN  
  
 insert into #tempEmpleadosRelaciones
 values (@IDJefe,@IDEmpleado, 'Esta relación ya existe.')
   
END


  
if exists(select * from #tempEmpleadosJefes j  
  where j.IDJefe in (select IDEmpleado from #tempEmpleadosSubordinados ))  
BEGIN  
  
 set @MessageError = 'El Empleado '+ @NombreCompletoTrabajando+ ' genera un referencia circular.'  
  

  insert into #tempEmpleadosRelaciones
  select IDJefe,IDEmpleado,'Esta relación genera referencia circular.' from #tempEmpleadosJefes j  
  where j.IDJefe in (select IDEmpleado from #tempEmpleadosSubordinados) 

 
END  
  
  select ER.IDJefe,
		 MJ.ClaveEmpleado ClaveJefe,
		 MJ.NOMBRECOMPLETO NombreCompletoJefe,
		 ER.IDEmpleado,
		 ME.ClaveEmpleado ClaveEmpleado,
		 ME.NOMBRECOMPLETO NombreCompletoEmpleado,
		 ER.Mensaje
  from #tempEmpleadosRelaciones ER
	inner join RH.tblEmpleadosMaster MJ
		on MJ.IDEmpleado = ER.IDJefe
	inner join RH.tblEmpleadosMaster ME
		on ME.IDEmpleado = ER.IDEmpleado
GO
