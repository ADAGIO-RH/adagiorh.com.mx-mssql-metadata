USE [p_adagioRHDusgem]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [RH].[spIUJefeEmpleado] --0, 66, 227,1
(    
  @IDJefeEmpleado int = 0    
 ,@IDEmpleado int      
 ,@IDJefe int     
 ,@IDUsuario int
 ,@remplazar  bit = 0   
) as    
 Declare @IDUsuarioTrabajando int    
   ,@NombreCompletoTrabajando varchar(255)    
   ,@NombreCompletoJefe varchar(255)    
   ,@MessageError varchar(255) 
   ,@CustomeProcedure Varchar(max)
   ,@ValidaNivelesJefeEmpleado int 
   ;    
   
    DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max);
    
  select Top 1 @NombreCompletoTrabajando = NombreCompleto from RH.tblEmpleadosMaster with(nolock) where IDEmpleado = @IDEmpleado    
  select Top 1 @NombreCompletoJefe = NombreCompleto from RH.tblEmpleadosMaster with(nolock) where IDEmpleado = @IDJefe    
  Select @IDUsuarioTrabajando = IDUsuario from Seguridad.tblUsuarios with(nolock) where IDEmpleado = @IDJefe 
 
 select @ValidaNivelesJefeEmpleado = cast(isnull(Valor,0) as int)from app.tblConfiguracionesGenerales with(nolock) where IDConfiguracion = 'ValidaNivelesJefeEmpleado'
  
 if (@IDJefe = @IDEmpleado) return;    
  
  
if object_id('tempdb..#tempEmpleadosSubordinados') is not null drop table #tempEmpleadosSubordinados;              
              
 create table #tempEmpleadosSubordinados (  
  IDJefe int  
  ,IDEmpleado int  
 )    
  
 ;With CteSubordinados    
 As    
 (    
  select fe.IDJefe,fe.IDEmpleado, cast(fe.IDJefe as varchar(MAX)) +' -> '+ cast(fe.IDEmpleado as varchar(max)) as [Path] ,1 AS Iteracion  
  from RH.tblJefesEmpleados fe  with(nolock)
   join [Seguridad].[TblUsuarios] u with(nolock) on u.IDEmpleado = fe.IDEmpleado  
  where fe.IDJefe = @IDEmpleado and fe.IDEmpleado not in (Select IDEmpleado from #tempEmpleadosSubordinados)            
  Union All    
  select fe.IDJefe,fe.IDEmpleado, CAST(cast(P.[Path] as varchar(max))+' -> '+ cast(fe.IDEmpleado as varchar(max)) AS varchar(max)) AS [path], Iteracion + 1  as Iteracion  
  from RH.tblJefesEmpleados fe  with(nolock)
  Inner Join CteSubordinados P On fe.IDJefe = p.IDEmpleado  
   join [Seguridad].[TblUsuarios] u with(nolock) on u.IDEmpleado = p.IDEmpleado  
  where  fe.IDEmpleado not in (Select IDEmpleado from #tempEmpleadosSubordinados)      
   and fe.IDJefe <>  @IDEmpleado      
   and  fe.IDJefe <> fe.IDEmpleado  
   and (Iteracion < @ValidaNivelesJefeEmpleado or isnull(@ValidaNivelesJefeEmpleado,0) = 0)
 )   
   
 insert into #tempEmpleadosSubordinados(IDJefe,IDEmpleado)            
 select cte.IDJefe,cte.IDEmpleado--,cte.Path, ROW_NUMBER()OVER(Partition by cte.IDJefe,cte.IDEmpleado order by CTE.IDEmpleado ) repetir  
 from CteSubordinados cte  
  join RH.tblEmpleadosMaster e with(nolock)on cte.IDEmpleado = e.IDEmpleado  
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
  select fe.IDJefe,fe.IDEmpleado, cast(fe.IDJefe as varchar(MAX)) +' -> '+ cast(fe.IDEmpleado as varchar(max)) as [Path]  ,1 AS Iteracion  
  from RH.tblJefesEmpleados fe  with(nolock)
   join [Seguridad].[TblUsuarios] u with(nolock) on u.IDEmpleado = fe.IDEmpleado  
  where fe.IDEmpleado = @IDJefe and fe.IDEmpleado not in (Select IDEmpleado from #tempEmpleadosJefes)            
  Union All    
  select fe.IDJefe,fe.IDEmpleado, CAST(cast(P.[Path] as varchar(max))+' -> '+ cast(fe.IDEmpleado as varchar(max)) AS varchar(max)) AS [path], Iteracion + 1  as Iteracion     
  from RH.tblJefesEmpleados fe with(nolock) 
  Inner Join CteJefes P On fe.IDJefe = p.IDEmpleado  
   join [Seguridad].[TblUsuarios] u with(nolock) on u.IDEmpleado = p.IDEmpleado  
  where  fe.IDJefe not in (Select IDEmpleado from #tempEmpleadosJefes)            
   and fe.IDEmpleado <>  @IDJefe      
   and  fe.IDEmpleado <> fe.IDEmpleado  
  and (Iteracion < @ValidaNivelesJefeEmpleado or isnull(@ValidaNivelesJefeEmpleado,0) = 0)
 )  
  
 insert into #tempEmpleadosJefes(IDJefe,IDEmpleado)    
 select cte.IDJefe,cte.IDEmpleado--,cte.Path, ROW_NUMBER()OVER(Partition by cte.IDJefe,cte.IDEmpleado order by CTE.IDEmpleado ) repetir  
 from CteJefes cte  
  join RH.tblEmpleadosMaster e with(nolock) on cte.IDEmpleado = e.IDEmpleado  
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

    if(@remplazar = 1)
    BEGIN
    delete [RH].[tblJefesEmpleados]
    where IDEmpleado = @IDEmpleado
    END

  insert into [RH].[tblJefesEmpleados](IDEmpleado,IDJefe)    
  select @IDEmpleado,@IDJefe    
    
		select @IDJefeEmpleado = @@IDENTITY;    

  		select @NewJSON = a.JSON from [RH].[tblJefesEmpleados] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDJefeEmpleado = @IDJefeEmpleado

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblJefesEmpleados]','[RH].[spIUJefeEmpleado]','INSERT',@NewJSON,''
     

 end else    
 begin    

		select @OldJSON = a.JSON from [RH].[tblJefesEmpleados] b with(nolock)
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDJefeEmpleado = @IDJefeEmpleado

  update [RH].[tblJefesEmpleados]    
  set IDJefe = @IDJefe    
  where IDJefeEmpleado = @IDJefeEmpleado 
  
  select @NewJSON = a.JSON from [RH].[tblJefesEmpleados] b with(nolock)
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDJefeEmpleado = @IDJefeEmpleado
print 'tucola'
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


--Ejecucion de Custom Procedure para JefesEmpleados
SELECT top 1 @CustomeProcedure = Valor FROM App.tblConfiguracionesGenerales WHERE IDConfiguracion = 'CustomProcedureJefesEmpleados'
IF(ISNULL(@CustomeProcedure,'') <> '')
	BEGIN
		exec sp_executesql N'exec @miSP @IDJefeEmpleado ,@IDEmpleado ,@IDJefe ,@IDUsuario'                   
			,N' @IDJefeEmpleado INT        
			,@IDEmpleado INT 
			,@IDJefe INT     
			,@IDUsuario INT      
			,@miSP varchar(MAX)',                          
			 @IDJefeEmpleado = @IDJefeEmpleado    
            ,@IDEmpleado = @IDEmpleado     
            ,@IDJefe = @IDJefe    
            ,@IDUsuario = @IDUsuario            
			,@miSP = @CustomeProcedure ; 	
    END
GO
