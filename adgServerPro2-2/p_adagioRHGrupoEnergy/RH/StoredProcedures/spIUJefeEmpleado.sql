USE [p_adagioRHGrupoEnergy]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [RH].[spIUJefeEmpleado] --0, 1325, 1279,1
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
   
    DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max);
    
  select Top 1 @NombreCompletoTrabajando = NombreCompleto from RH.tblEmpleadosMaster where IDEmpleado = @IDEmpleado    
  select Top 1 @NombreCompletoJefe = NombreCompleto from RH.tblEmpleadosMaster where IDEmpleado = @IDJefe    
 Select @IDUsuarioTrabajando = IDUsuario from Seguridad.tblUsuarios where IDEmpleado = @IDJefe    
  
 if (@IDJefe = @IDEmpleado) return;    
  
  
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
  
 set @MessageError = 'Ya existe una relación previa entre '+ @NombreCompletoTrabajando+ ' y '+ @NombreCompletoJefe + '.'  
  
  EXEC [App].[spObtenerError]    
  @IDUsuario = @IDUsuario,    
  @CodigoError = '0302006',    
  @CustomMessage  = @MessageError    
  return;  
END


  
if exists(select * from #tempEmpleadosJefes j  
  where j.IDJefe in (select IDEmpleado from #tempEmpleadosSubordinados ))  
BEGIN  
  
 set @MessageError = 'El Empleado '+ @NombreCompletoTrabajando+ ' genera un referencia circular.'  
  
  EXEC [App].[spObtenerError]    
  @IDUsuario = @IDUsuario,    
  @CodigoError = '0302006',    
  @CustomMessage  = @MessageError    
  return;  
END  
  
  
    
 if (@IDJefeEmpleado = 0) and not exists(select top 1 1     
           from [RH].[tblJefesEmpleados]    
           where IDEmpleado = @IDEmpleado and IDJefe = @IDJefe    
           )    
 begin    
  insert into [RH].[tblJefesEmpleados](IDEmpleado,IDJefe)    
  select @IDEmpleado,@IDJefe    
    
		select @IDJefeEmpleado = @@IDENTITY;    

  		select @NewJSON = a.JSON from [RH].[tblJefesEmpleados] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDJefeEmpleado = @IDJefeEmpleado

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblJefesEmpleados]','[RH].[spIUJefeEmpleado]','INSERT',@NewJSON,''
     

 end else    
 begin    

		select @OldJSON = a.JSON from [RH].[tblJefesEmpleados] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDJefeEmpleado = @IDJefeEmpleado

  update [RH].[tblJefesEmpleados]    
  set IDJefe = @IDJefe    
  where IDJefeEmpleado = @IDJefeEmpleado 
  
  select @NewJSON = a.JSON from [RH].[tblJefesEmpleados] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDJefeEmpleado = @IDJefeEmpleado

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblJefesEmpleados]','[RH].[spIUJefeEmpleado]','UPDATE',@NewJSON,@OldJSON     
 end;    
    
	print 'wey'
 exec [RH].[spActualizarTotalesRelacionesEmpleados] @IDEmpleado, @IDEmpleado    
    
 exec [RH].[spBuscarJefesEmpleados] @IDJefeEmpleado = @IDJefeEmpleado, @IDUsuario = @IDUsuario    
    print 'wey2' 
  
    
 EXEC [Seguridad].[spIUFiltrosUsuarios]     
  @IDFiltrosUsuarios  = 0      
  ,@IDUsuario  = @IDUsuarioTrabajando       
  ,@Filtro = 'Empleados'      
  ,@ID = @IDEmpleado       
  ,@Descripcion = @NombreCompletoTrabajando    
  ,@IDUsuarioLogin = @IDUsuario     
    
	print 'wey3'
  exec [RH].[spSchedulerActualizarTotalesRelacionesEmpleados] @IDUsuario = @IDUsuarioTrabajando, @IDUsuarioLogin = @IDUsuario       
  --exec [Seguridad].[spAsginarEmpleadosAUsuarioPorFiltro] @IDUsuario = @IDUsuarioTrabajando, @IDUsuarioLogin = @IDUsuario 
GO
