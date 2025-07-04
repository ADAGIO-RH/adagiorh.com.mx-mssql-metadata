USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
         
create procedure [BK].[spAsginarEmpleadosAUsuarioPorFiltro]-- 1,1            
(              
 @IDUsuario int = 0             
 ,@IDUsuarioLogin int              
) as              

--declare 
--	@IDUsuario int = 49            
--	,@IDUsuarioLogin int = 1     
	          
declare               
	@dtFiltros [Nomina].[dtFiltrosRH]               
	,@empleados [RH].[dtEmpleados]  
    
	,@IDUsuarioTrabajando int            
	,@IDPerfilTrabajando int            
	,@IDEmpleadoTrabajando int       
	,@NombreCompletoTrabajando Varchar(255)    
	,@IDPerfilUsuarioDefault int   
	,@IDUsuarioAdmin int    
;              
           
	if object_id('tempdb..#tempFinalEmpleados') is not null drop table #tempFinalEmpleados;              
              
	create table #tempFinalEmpleados (  
		IDUsuario int  
		,IDEmpleado int  
		,TipoFiltro varchar(255) collate database_default  
		,ValorFiltro varchar(255) collate database_default  
	)              
	 
	Select top 1 @IDPerfilUsuarioDefault = Valor from App.tblConfiguracionesGenerales where IDConfiguracion = 'IDPerfilDefaultEmpleados'    
	Select top 1 @IDUsuarioAdmin = Valor from App.tblConfiguracionesGenerales where IDConfiguracion = 'IDUsuarioAdmin'    
            
	select 
		 @IDUsuarioTrabajando		= U.IDUsuario
		,@IDPerfilTrabajando		= U.IDPerfil
		,@IDEmpleadoTrabajando		= U.IDEmpleado
		,@NombreCompletoTrabajando	= e.NOMBRECOMPLETO            
	From Seguridad.tblUsuarios U         
		left join RH.tblEmpleadosMaster E on U.IDEmpleado = E.IDEmpleado           
	where (U.IDUsuario = @IDUsuario) OR (@IDUsuario = 0)            
            
	BEGIN-- SELF            
		insert into #tempFinalEmpleados(IDUsuario,IDEmpleado,TipoFiltro, ValorFiltro)            
		select @IDUsuarioTrabajando,IDEmpleado,'Empleados', 'Empleados | '+ NOMBRECOMPLETO            
		from RH.tblEmpleadosMaster with (nolock)           
		where IDEmpleado = @IDEmpleadoTrabajando and IDEmpleado not in (Select IDEmpleado from #tempFinalEmpleados)            
	END-- SELF       
    
	BEGIN	--SUBORDINADOS      
		declare  @tblTempSubordinados table(    
			IDEmpleado int   
		);  
  
		;With CteSubordinados    
		As    
		(    
			select fe.IDEmpleado  
			from RH.tblJefesEmpleados fe  
				join [Seguridad].[TblUsuarios] u on u.IDEmpleado = fe.IDEmpleado  
			where fe.IDJefe = @IDEmpleadoTrabajando and fe.IDEmpleado not in (Select IDEmpleado from #tempFinalEmpleados)            
			Union All    
			select fe.IDEmpleado  
			from RH.tblJefesEmpleados fe  
				Inner Join CteSubordinados P On fe.IDJefe = p.IDEmpleado  
				join [Seguridad].[TblUsuarios] u on u.IDEmpleado = p.IDEmpleado  
			where  fe.IDEmpleado not in (Select IDEmpleado from #tempFinalEmpleados)            
		)    
  
		insert into #tempFinalEmpleados(IDUsuario,IDEmpleado,TipoFiltro,ValorFiltro)            
		select @IDUsuarioTrabajando,cte.IDEmpleado,'Empleados','Empleados | '+ e.NOMBRECOMPLETO   
		from CteSubordinados cte  
			join RH.tblEmpleadosMaster e on cte.IDEmpleado = e.IDEmpleado 
			and cte.IDEmpleado not in (Select IDEmpleado from #tempFinalEmpleados )
		OPTION (MAXRECURSION 0);  
    
		insert into #tempFinalEmpleados(IDUsuario,IDEmpleado,TipoFiltro,ValorFiltro)            
		select  @IDUsuarioTrabajando,IDEmpleado,'Empleados','Empleados | '+ NOMBRECOMPLETO              
		from RH.tblEmpleadosMaster            
		WHERE IDEmpleado in (            
			 select IDEmpleado             
			 from RH.tblJefesEmpleados            
			 where IDJefe = @IDEmpleadoTrabajando)            
		and IDEmpleado not in (Select IDEmpleado from #tempFinalEmpleados)            
	END	--SUBORDINADOS    
       
	IF exists(select Top 1 1 from Seguridad.tblFiltrosUsuarios where IDUsuario = @IDUsuarioTrabajando)            
	BEGIN            
		--FILTROS            
		--ClasificacionesCorporativas            
		insert into #tempFinalEmpleados(IDUsuario,IDEmpleado,TipoFiltro, ValorFiltro)            
		select  @IDUsuarioTrabajando,IDEmpleado,'ClasificacionesCorporativas', 'ClasificacionesCorporativas | '+ ClasificacionCorporativa            
		from RH.tblEmpleadosMaster            
		WHERE IDClasificacionCorporativa in (            
											Select ID 
											from Seguridad.tblFiltrosUsuarios                 
											where IDUsuario = @IDUsuario and Filtro = 'ClasificacionesCorporativas')            
		and IDEmpleado not in (Select IDEmpleado from #tempFinalEmpleados)            
            
		--Clientes            
		insert into #tempFinalEmpleados(IDUsuario,IDEmpleado,TipoFiltro,ValorFiltro)            
		select  @IDUsuarioTrabajando,IDEmpleado,'Clientes', 'Clientes | '+ Cliente             
		from RH.tblEmpleadosMaster            
		WHERE IDCliente in (            
						Select ID from Seguridad.tblFiltrosUsuarios            
						where IDUsuario = @IDUsuario            
						and Filtro = 'Clientes')            
		and IDEmpleado not in (Select IDEmpleado from #tempFinalEmpleados)  
            
		--Departamentos            
		insert into #tempFinalEmpleados(IDUsuario,IDEmpleado,TipoFiltro, ValorFiltro)            
		select  @IDUsuarioTrabajando,IDEmpleado,'Departamentos','Departamentos | '+ Departamento              
		from RH.tblEmpleadosMaster            
		WHERE IDDepartamento in (            
			Select ID from Seguridad.tblFiltrosUsuarios            
			where IDUsuario = @IDUsuario            
			and Filtro = 'Departamentos')            
		and IDEmpleado not in (Select IDEmpleado from #tempFinalEmpleados)            
	
		--Divisiones            
		insert into #tempFinalEmpleados(IDUsuario,IDEmpleado,TipoFiltro, ValorFiltro)            
		select  @IDUsuarioTrabajando,IDEmpleado,'Divisiones', 'Divisiones | '+ Division              
		from RH.tblEmpleadosMaster            
		WHERE IDDivision in (            
			Select ID from Seguridad.tblFiltrosUsuarios            
			where IDUsuario = @IDUsuario            
			and Filtro = 'Divisiones')            
		and IDEmpleado not in (Select IDEmpleado from #tempFinalEmpleados)            
	
		--Empleados            
		insert into #tempFinalEmpleados(IDUsuario,IDEmpleado,TipoFiltro, ValorFiltro)            
		select  @IDUsuarioTrabajando,IDEmpleado,'Empleados', 'Empleados | '+ NOMBRECOMPLETO             
		from RH.tblEmpleadosMaster            
		WHERE IDEmpleado in (            
			Select ID from Seguridad.tblFiltrosUsuarios            
			where IDUsuario = @IDUsuario            
			and Filtro = 'Empleados')            
		and IDEmpleado not in (Select IDEmpleado from #tempFinalEmpleados)            
               
		--Prestaciones            
		insert into #tempFinalEmpleados(IDUsuario,IDEmpleado,TipoFiltro, ValorFiltro)            
		select  @IDUsuarioTrabajando,IDEmpleado,'Prestaciones', 'Prestaciones | '+t.Descripcion              
		from RH.tblEmpleadosMaster E          
		inner join RH.tblCatTiposPrestaciones t          
		on e.IDTipoPrestacion = t.IDTipoPrestacion            
		WHERE e.IDTipoPrestacion in (            
			Select ID from Seguridad.tblFiltrosUsuarios            
			where IDUsuario = @IDUsuario            
			and Filtro = 'Prestaciones')            
		and e.IDEmpleado not in (Select IDEmpleado from #tempFinalEmpleados)            
	
		--Puestos            
		insert into #tempFinalEmpleados(IDUsuario,IDEmpleado,TipoFiltro,ValorFiltro)            
		select  @IDUsuarioTrabajando,IDEmpleado,'Puestos' ,'Puestos | '+ Puesto             
		from RH.tblEmpleadosMaster            
		WHERE IDPuesto in (            
			Select ID from Seguridad.tblFiltrosUsuarios            
			where IDUsuario = @IDUsuario            
			and Filtro = 'Puestos')            
		and IDEmpleado not in (Select IDEmpleado from #tempFinalEmpleados)            
	
		--RazonesSociales            
		insert into #tempFinalEmpleados(IDUsuario,IDEmpleado,TipoFiltro,ValorFiltro)            
		select  @IDUsuarioTrabajando,IDEmpleado,'RazonesSociales','RazonesSociales | '+Empresa             
		from RH.tblEmpleadosMaster            
		WHERE IDEmpresa in (            
			Select ID from Seguridad.tblFiltrosUsuarios            
			where IDUsuario = @IDUsuario            
			and Filtro = 'RazonesSociales')            
		and IDEmpleado not in (Select IDEmpleado from #tempFinalEmpleados)            
	
		--RegPatronales          
		insert into #tempFinalEmpleados(IDUsuario,IDEmpleado,TipoFiltro, ValorFiltro)            
		select  @IDUsuarioTrabajando,IDEmpleado,'RegPatronales' ,'RegPatronales | '+ RegPatronal             
		from RH.tblEmpleadosMaster            
		WHERE IDRegPatronal in (            
			Select ID from Seguridad.tblFiltrosUsuarios            
			where IDUsuario = @IDUsuario            
			and Filtro = 'RegPatronales')            
		and IDEmpleado not in (Select IDEmpleado from #tempFinalEmpleados)              --Sucursales            
	
		insert into #tempFinalEmpleados(IDUsuario,IDEmpleado,TipoFiltro, ValorFiltro)            
		select  @IDUsuarioTrabajando,IDEmpleado,'Sucursales', 'Sucursales | '+Sucursal           
		from RH.tblEmpleadosMaster            
		WHERE IDSucursal in (            
			Select ID from Seguridad.tblFiltrosUsuarios            
			where IDUsuario = @IDUsuario            
			and Filtro = 'Sucursales')            
		and IDEmpleado not in (Select IDEmpleado from #tempFinalEmpleados)            
	
		--TiposContratacion            
		insert into #tempFinalEmpleados(IDUsuario,IDEmpleado,TipoFiltro, ValorFiltro)            
		select  @IDUsuarioTrabajando,IDEmpleado,'TiposContratacion', 'TiposContratacion | '+ TipoContrato           
		from RH.tblEmpleadosMaster            
		WHERE IDTipoContrato in (            
			Select ID from Seguridad.tblFiltrosUsuarios            
			where IDUsuario = @IDUsuario            
			and Filtro = 'TiposContratacion')            
		and IDEmpleado not in (Select IDEmpleado from #tempFinalEmpleados)            
	
		--TiposNomina             
		insert into #tempFinalEmpleados(IDUsuario,IDEmpleado,TipoFiltro,ValorFiltro)            
		select  @IDUsuarioTrabajando,IDEmpleado,'TiposNomina', 'TiposNomina | '+ TipoNomina          
		from RH.tblEmpleadosMaster            
		WHERE IDTipoNomina in (            
			Select ID from Seguridad.tblFiltrosUsuarios            
			where IDUsuario = @IDUsuario            
			and Filtro = 'TiposNomina')            
		and IDEmpleado not in (Select IDEmpleado from #tempFinalEmpleados)            
            
		--Excluir Empleado            
		Delete             
		from #tempFinalEmpleados            
		WHERE IDEmpleado in (            
			Select ID from Seguridad.tblFiltrosUsuarios            
			where IDUsuario = @IDUsuario            
			and Filtro = 'Excluir Empleado')            
	--FILTROS            
	END            
	ELSE IF (@IDPerfilTrabajando <> @IDPerfilUsuarioDefault)             
	BEGIN            
		insert into #tempFinalEmpleados(IDUsuario,IDEmpleado,TipoFiltro, ValorFiltro)            
		select  @IDUsuarioTrabajando,IDEmpleado,'Empleados' , 'Empleados | '+ NOMBRECOMPLETO           
		from RH.tblEmpleadosMaster            
		WHERE IDEmpleado not in (Select IDEmpleado from #tempFinalEmpleados)             
	END         

	if object_id('tempdb..#tempFinalEmpleadosLimpios') is not null drop table #tempFinalEmpleadosLimpios;   
	  
	select * , Row_Number()Over(Partition by IDEmpleado order by IDUsuario) as RN 
	into #tempFinalEmpleadosLimpios
	from #tempFinalEmpleados

	delete #tempFinalEmpleadosLimpios
	where RN > 1

	--select * from #tempFinalEmpleadosLimpios
	MERGE Seguridad.tblDetalleFiltrosEmpleadosUsuarios AS TARGET            
	USING #tempFinalEmpleadosLimpios AS SOURCE             
		ON (TARGET.IDUsuario = SOURCE.IDUsuario)             
		AND (TARGET.IDEmpleado = SOURCE.IDEmpleado )            
		AND (TARGET.Filtro = SOURCE.TipoFiltro)           
		AND  (TARGET.ValorFiltro = SOURCE.ValorFiltro)           
		--When records are matched, update the records if there is any change            
	WHEN MATCHED             
		THEN UPDATE             
		SET TARGET.IDUsuario = SOURCE.IDUsuario            
		, TARGET.IDEmpleado = SOURCE.IDEmpleado            
		, TARGET.Filtro = SOURCE.TipoFiltro          
		, TARGET.ValorFiltro = SOURCE.ValorFiltro          
              
	--When no records are matched, insert the incoming records from source table to target table            
	WHEN NOT MATCHED BY TARGET             
		THEN INSERT (IDUsuario, IDEmpleado, Filtro,ValorFiltro)             
		VALUES (SOURCE.IDUsuario, SOURCE.IDEmpleado, SOURCE.TipoFiltro,SOURCE.ValorFiltro)            
	--When there is a row that exists in target and same record does not exist in source then delete this record target            
	WHEN NOT MATCHED BY SOURCE  and Target.IDUsuario = @IDUsuario      
		THEN DELETE;  
  --$action specifies a column of type nvarchar(10) in the OUTPUT clause that returns             
  --one of three values for each row: 'INSERT', 'UPDATE', or 'DELETE' according to the action that was performed on that row            
  --OUTPUT $action,            --DELETED.IDUsuario AS IDUsuario,             
  --DELETED.IDEmpleado AS IDEmpleado,             
  --DELETED.Filtro AS Filtro,             
  --INSERTED.IDUsuario AS IDUsuario,             
  --INSERTED.IDEmpleado AS IDEmpleado,             
  --INSERTED.Filtro AS Filtro;             
	drop table #tempFinalEmpleados;
GO
