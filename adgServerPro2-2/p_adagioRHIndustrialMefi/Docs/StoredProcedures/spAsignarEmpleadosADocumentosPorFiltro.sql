USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec [Docs].[spAsignarEmpleadosADocumentosPorFiltro] 22
CREATE procedure [Docs].[spAsignarEmpleadosADocumentosPorFiltro]--16
(              
	@IDDocumento int = 0             
         
) as              

--declare 
--	@IDUsuario int = 49            
--	,@IDUsuarioLogin int = 1     
	declare               
		@dtFiltros [Nomina].[dtFiltrosRH]               
		,@dtFiltrosEmpleados [Nomina].[dtFiltrosRH]               
		,@empleados [RH].[dtEmpleados]  
		,@empleados2 [RH].[dtEmpleados]  
    
		,@IDDocumentoTrabajando int            
		,@IDUsuarioCreador int       
		,@NombreCompletoTrabajando Varchar(255)    
		,@IDPerfilUsuarioDefault int   
		,@IDUsuarioAdmin int   
		,@i int = 0 
		,@Grupo varchar(255)
		,@IDTipoNomina int = 0
		,@soloVigentes bit = 0
	
	;              

	if object_id('tempdb..#tempUsuarios') is not null drop table #tempUsuarios;              
              
	create table #tempUsuarios (  
		IDUsuario int  
		,Cuenta varchar(255) collate database_default 
		,Nombre varchar(255) collate database_default 
		,Apellido varchar(255) collate database_default 
		,IDEmpleado int null
		,Departamento varchar(255) collate database_default 
		,Sucursal varchar(255) collate database_default 
		,Puesto varchar(255) collate database_default 
	); 

	if object_id('tempdb..#tempUsuarios2') is not null drop table #tempUsuarios2;              
              
	create table #tempUsuarios2 (  
		IDUsuario int  
		,Cuenta varchar(255) collate database_default 
		,Nombre varchar(255) collate database_default 
		,Apellido varchar(255) collate database_default 
		,IDEmpleado int null
		,Departamento varchar(255) collate database_default 
		,Sucursal varchar(255) collate database_default 
		,Puesto varchar(255) collate database_default 
	); 
	  
	insert into #tempUsuarios2(IDUsuario,Cuenta,Nombre,Apellido,IDEmpleado,Departamento,Sucursal,Puesto)
	select u.IDUsuario,u.Cuenta,u.Nombre,u.Apellido,u.IDEmpleado,m.Departamento,m.Sucursal,m.Puesto
	from Seguridad.tblUsuarios u with(nolock)
		left join RH.tblEmpleadosMaster M with(nolock)
			on u.IDEmpleado = M.IDEmpleado

			--select * from #tempUsuarios2


	if object_id('tempdb..#tempFinalUsuarios') is not null drop table #tempFinalUsuarios;              
              
	create table #tempFinalUsuarios (  
		IDDocumento int  
		,IDUsuario int  
		,TipoFiltro varchar(255) collate database_default  
		,ValorFiltro varchar(255) collate database_default  
		,IDCatFiltroDocumento int
	);             
	 
	Select top 1 @IDUsuarioAdmin = Valor from App.tblConfiguracionesGenerales with (nolock) where IDConfiguracion = 'IDUsuarioAdmin'    
            
	select 
		 @IDDocumentoTrabajando		= U.IDItem
		,@IDUsuarioCreador			= isnull(U.IDPublicador,1)
	     
	From Docs.tblCarpetasDocumentos U with (nolock)         
		left join #tempUsuarios E on isnull(U.IDPublicador,1) = E.IDUsuario           
	   where u.IDItem = @IDDocumento   
       
	  --select  @IDDocumentoTrabajando as IDDocumentoTrabajando
	  -- , @IDUsuarioCreador	as IDUsuarioCreador	    
		    
	BEGIN-- SELF -- ADMIN            
		insert into #tempFinalUsuarios(IDDocumento,IDUsuario,TipoFiltro, ValorFiltro)            
		select @IDDocumentoTrabajando,IDUsuario,'Usuario', 'Usuario | '+ Cuenta+' - '+Nombre + ' '+ Apellido            
		from #tempUsuarios       
		where IDUsuario = @IDUsuarioCreador and IDUsuario not in (Select IDEmpleado from #tempFinalUsuarios) 
		
		insert into #tempFinalUsuarios(IDDocumento,IDUsuario,TipoFiltro, ValorFiltro)            
		select @IDDocumentoTrabajando,IDUsuario,'Usuario', 'Usuario | '+ Cuenta+' - '+Nombre + ' '+ Apellido            
		from #tempUsuarios       
		where IDUsuario = 1 and IDUsuario not in (Select IDEmpleado from #tempFinalUsuarios)  
		           
	END-- SELF       
    --select * from #tempFinalUsuarios

       
	if exists (
		select top 1 1 from Docs.tblCatFiltrosDocumentos with (nolock) where IDDocumento = @IDDocumentoTrabajando
	)
	BEGIN
		--select 'Existe  Docs.tblCatFiltrosDocumentos'
		select @i=min(IDCatFiltroDocumento) from Docs.tblCatFiltrosDocumentos with (nolock) where IDDocumento = @IDDocumentoTrabajando
		print @i
		while exists(select top 1 1 from Docs.tblCatFiltrosDocumentos with (nolock) where IDDocumento = @IDDocumentoTrabajando and IDCatFiltroDocumento >= @i )
		begin
		--select 'Existe  Docs.tblCatFiltrosDocumentos 2'

			delete from @dtFiltros
			delete from @dtFiltrosEmpleados
			delete from @empleados						

			select @Grupo = cfu.Nombre
			from Docs.tblCatFiltrosDocumentos cfu with (nolock)
				join Docs.tblFiltrosDocumentos fu with (nolock) on cfu.IDCatFiltroDocumento = fu.IDCatFiltroDocumento
			where cfu.IDCatFiltroDocumento = @i

			--select @Grupo
 
			insert into @dtFiltros(Catalogo,Value)
			SELECT Filtro, 
			 STUFF(
				(SELECT ', '  + fu.ID
					FROM Docs.tblCatFiltrosDocumentos cfu with (nolock)
					join Docs.tblFiltrosDocumentos fu with (nolock) on cfu.IDCatFiltroDocumento = fu.IDCatFiltroDocumento  and fu.Filtro = fu2.Filtro
					where cfu.IDCatFiltroDocumento = @i
				FOR XML PATH('')),
				1, 2, '') As [Value]
			FROM Docs.tblCatFiltrosDocumentos cfu2 with (nolock)
				join Docs.tblFiltrosDocumentos fu2 with (nolock) on cfu2.IDCatFiltroDocumento = fu2.IDCatFiltroDocumento
			where cfu2.IDCatFiltroDocumento = @i
			and fu2.Filtro <> 'Usuarios'
			and fu2.Filtro <> 'Excluir Usuarios'
			group by Filtro

			--select * from @dtFiltros

			insert into @dtFiltrosEmpleados(Catalogo,Value)
			SELECT Filtro, 
			 STUFF(
				(SELECT ', '  + fu.ID
					FROM Docs.tblCatFiltrosDocumentos cfu with (nolock)
					join Docs.tblFiltrosDocumentos  fu with (nolock) on cfu.IDCatFiltroDocumento = fu.IDCatFiltroDocumento  and fu.Filtro = fu2.Filtro
					where cfu.IDCatFiltroDocumento = @i
				FOR XML PATH('')),
				1, 2, '') As [Value]
			FROM Docs.tblCatFiltrosDocumentos cfu2 with (nolock)
				join Docs.tblFiltrosDocumentos fu2 with (nolock) on cfu2.IDCatFiltroDocumento = fu2.IDCatFiltroDocumento
			where cfu2.IDCatFiltroDocumento = @i
			and (fu2.Filtro = 'Usuarios'  or fu2.Filtro = 'Excluir Usuarios')
			group by Filtro

			--select * from @dtFiltrosEmpleados
					--select * from #tempUsuarios
					--select * from @dtFiltrosEmpleados
				insert into #tempUsuarios(IDUsuario,Cuenta,Nombre,Apellido,IDEmpleado,Departamento,Sucursal,Puesto)
				select u.IDUsuario,u.Cuenta,u.Nombre,u.Apellido,u.IDEmpleado,M.Departamento,M.Sucursal,M.Puesto
				from #tempUsuarios2 u
					left join RH.tblEmpleadosMaster M with(nolock)
						on u.IDEmpleado = m.IDEmpleado
				where 
				    ((M.IDDepartamento in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Departamentos'),','))               
					   or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Departamentos' and isnull(Value,'')<>''))))              
				   and ((M.IDSucursal in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Sucursales'),','))               
					  or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Sucursales' and isnull(Value,'')<>''))))              
				   and ((M.IDPuesto in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Puestos'),','))               
					 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Puestos' and isnull(Value,'')<>''))))              
					and ((u.IDUsuario in (Select item from App.Split((Select top 1 Value from @dtFiltrosEmpleados where Catalogo = 'Usuarios'),','))               
					   or (Not exists(Select 1 from @dtFiltrosEmpleados where Catalogo = 'Usuarios' and isnull(Value,'')<>''))))              
				   and ((u.IDUsuario not in (Select item from App.Split((Select top 1 Value from @dtFiltrosEmpleados where Catalogo = 'Excluir Usuarios'),','))               
					   or (Not exists(Select 1 from @dtFiltrosEmpleados where Catalogo = 'Excluir Usuarios' and isnull(Value,'')<>'')))) 

				--insert into #tempUsuarios(IDUsuario,Cuenta,Nombre,Apellido,IDEmpleado,Departamento,Sucursal,Puesto)
				--select u.IDUsuario,u.Cuenta,u.Nombre,u.Apellido,u.IDEmpleado,M.Departamento,M.Sucursal,M.Puesto
				--from #tempUsuarios2 u
				--	left join RH.tblEmpleadosMaster M with(nolock)
				--		on u.IDEmpleado = m.IDEmpleado
				--where 
				--   ((u.IDUsuario in (Select item from App.Split((Select top 1 Value from @dtFiltrosEmpleados where Catalogo = 'Usuarios'),','))               
				--	   or (Not exists(Select 1 from @dtFiltrosEmpleados where Catalogo = 'Usuarios' and isnull(Value,'')<>''))))              
				          
				--	select * from #tempUsuarios

			insert into #tempFinalUsuarios(IDDocumento,IDUsuario,TipoFiltro,ValorFiltro,IDCatFiltroDocumento)            
			select @IDDocumentoTrabajando,IDUsuario,'Usuarios' , 'Usuarios | '+ Cuenta+' - '+Nombre + ' '+ Apellido,@i       
			from #tempUsuarios          
			WHERE IDUsuario not in (Select IDUsuario from #tempFinalUsuarios)            
            
			--insert into #tempFinalEmpleados(IDUsuario,IDEmpleado,TipoFiltro,ValorFiltro,IDCatFiltroUsuario)            
			--select @IDUsuarioTrabajando,IDEmpleado,'Empleados' , 'Empleados | '+ NOMBRECOMPLETO,@i        
			--from @empleados2          
			--WHERE IDEmpleado not in (Select IDEmpleado from #tempFinalEmpleados)     

			select @i=min(IDCatFiltroDocumento) from Docs.tblCatFiltrosDocumentos where IDDocumento = @IDDocumentoTrabajando and IDCatFiltroDocumento > @i
		END;
		
	END
	ELSE            
	BEGIN            
		insert into #tempFinalUsuarios(IDDocumento,IDUsuario,TipoFiltro, ValorFiltro,IDCatFiltroDocumento)            
		select  @IDDocumentoTrabajando,IDUsuario,'Usuarios' , 'Usuarios | '+ Cuenta+' - '+Nombre + ' '+ Apellido  ,@i          
		from #tempUsuarios2
		WHERE IDUsuario not in (Select IDUsuario from #tempFinalUsuarios)             
	END      

	if object_id('tempdb..#tempFinalUsuariosLimpios') is not null drop table #tempFinalUsuariosLimpios;   
	  
	select * , Row_Number()Over(Partition by IDUsuario order by IDUsuario) as RN 
	into #tempFinalUsuariosLimpios
	from #tempFinalUsuarios
	

	delete #tempFinalUsuariosLimpios
	where RN > 1


	--select * from #tempFinalUsuariosLimpios

	MERGE Docs.tblDetalleFiltrosDocumentosUsuarios AS TARGET            
	USING #tempFinalUsuariosLimpios AS SOURCE             
		ON (TARGET.IDDocumento = SOURCE.IDDocumento)             
			AND (TARGET.IDUsuario = SOURCE.IDUsuario )            
			AND (TARGET.Filtro = SOURCE.TipoFiltro)           
			AND (TARGET.ValorFiltro = SOURCE.ValorFiltro)           
			AND (TARGET.IDCatFiltroDocumento = SOURCE.IDCatFiltroDocumento)           
		--When records are matched, update the records if there is any change            
	WHEN MATCHED             
		THEN UPDATE             
		SET TARGET.IDDocumento			= SOURCE.IDDocumento            
			,TARGET.IDUsuario			= SOURCE.IDUsuario            
			,TARGET.Filtro				= SOURCE.TipoFiltro          
			,TARGET.ValorFiltro			= SOURCE.ValorFiltro          
			,TARGET.IDCatFiltroDocumento	= SOURCE.IDCatFiltroDocumento          
              
	--When no records are matched, insert the incoming records from source table to target table            
	WHEN NOT MATCHED BY TARGET             
		THEN INSERT (IDDocumento, IDUsuario, Filtro,ValorFiltro,IDCatFiltroDocumento)             
		VALUES (SOURCE.IDDocumento, SOURCE.IDUsuario, SOURCE.TipoFiltro,SOURCE.ValorFiltro,SOURCE.IDCatFiltroDocumento)            
	--When there is a row that exists in target and same record does not exist in source then delete this record target            
	WHEN NOT MATCHED BY SOURCE  and Target.IDDocumento = @IDDocumentoTrabajando    
		THEN DELETE;  
  --$action specifies a column of type nvarchar(10) in the OUTPUT clause that returns             
  --one of three values for each row: 'INSERT', 'UPDATE', or 'DELETE' according to the action that was performed on that row            
  --OUTPUT $action,            --DELETED.IDUsuario AS IDUsuario,             
  --DELETED.IDEmpleado AS IDEmpleado,             
  --DELETED.Filtro AS Filtro,             
  --INSERTED.IDUsuario AS IDUsuario,             
  --INSERTED.IDEmpleado AS IDEmpleado,             
  --INSERTED.Filtro AS Filtro;             
	drop table #tempFinalUsuarios;
GO
