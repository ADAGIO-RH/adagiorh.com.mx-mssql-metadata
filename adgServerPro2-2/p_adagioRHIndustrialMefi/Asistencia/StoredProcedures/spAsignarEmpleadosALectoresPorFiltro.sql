USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* 
[Asistencia].[spAsignarEmpleadosALectoresPorFiltro]1059,1
*/
CREATE   procedure [Asistencia].[spAsignarEmpleadosALectoresPorFiltro]
(              
	@IDLector int = 0             
	,@IDUsuarioLogin int  
	,@dtEmpleadosMaster [RH].[dtEmpleados] readonly            
) as              

	declare               
		@dtFiltros [Nomina].[dtFiltrosRH]               
		,@dtFiltrosEmpleados [Nomina].[dtFiltrosRH]               
		,@empleados [RH].[dtEmpleados]  
		,@empleados2 [RH].[dtEmpleados]  
    
		,@IDLectorTrabajando int            
		,@NombreLectorTrabajando Varchar(255)    
		,@IDPerfilUsuarioDefault int   
		,@IDUsuarioAdmin int   
		,@i int = 0 
		,@Grupo varchar(255)
		,@IDTipoNomina int = 0
		,@soloVigentes bit = 0
		,@AsignarTodosLosColaboradores bit = 0
		,@DevSN Varchar(50)
		,@Configuracion Varchar(max)
	;              

	select @DevSN = NumeroSerial, @Configuracion = Configuracion from Asistencia.tblLectores with(nolock) where IDLector = @IDLector
	
	if object_id('tempdb..#tempFinalEmpleados') is not null drop table #tempFinalEmpleados;              
	if object_id('tempdb..#tempFinalEmpleadosLimpios') is not null drop table #tempFinalEmpleadosLimpios;   
	 
	if not exists(select top 1 1 from @dtEmpleadosMaster)
	begin
		insert @empleados2(IDEmpleado,ClaveEmpleado,Paterno,Materno,SegundoNombre,Nombre,NOMBRECOMPLETO,IDTipoNomina,IDDepartamento,IDSucursal,IDPuesto,IDTipoPrestacion,IDCliente,IDTipoContrato,IdEmpresa,IDRegPatronal,IDDivision,IDClasificacionCorporativa,Vigente,IDCentroCosto,IDArea,IDRegion)
		select e.IDEmpleado,ClaveEmpleado,Paterno,Materno,SegundoNombre,Nombre,NOMBRECOMPLETO,IDTipoNomina,IDDepartamento,IDSucursal,IDPuesto,IDTipoPrestacion,IDCliente,IDTipoContrato,IdEmpresa,IDRegPatronal,IDDivision,IDClasificacionCorporativa,Vigente,IDCentroCosto,IDArea,IDRegion
		from RH.tblEmpleadosMaster e with (nolock)
			join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on e.IDEmpleado = dfe.IDEmpleado and dfe.IDUsuario = @IDUsuarioLogin
	end else
	begin
		insert @empleados2(IDEmpleado,ClaveEmpleado,Paterno,Materno,SegundoNombre,Nombre,NOMBRECOMPLETO,IDTipoNomina,IDDepartamento,IDSucursal,IDPuesto,IDTipoPrestacion,IDCliente,IDTipoContrato,IdEmpresa,IDRegPatronal,IDDivision,IDClasificacionCorporativa,Vigente,IDCentroCosto,IDArea,IDRegion)
		select IDEmpleado,ClaveEmpleado,Paterno,Materno,SegundoNombre,Nombre,NOMBRECOMPLETO,IDTipoNomina,IDDepartamento,IDSucursal,IDPuesto,IDTipoPrestacion,IDCliente,IDTipoContrato,IdEmpresa,IDRegPatronal,IDDivision,IDClasificacionCorporativa,Vigente,IDCentroCosto,IDArea,IDRegion
		from @dtEmpleadosMaster
	end;

	delete @empleados2 where Vigente = 0
              
	create table #tempFinalEmpleados (  
		IDLector int  
		,IDEmpleado int  
		,TipoFiltro varchar(255) collate database_default  
		,ValorFiltro varchar(255) collate database_default  
		,IDGrupoFiltrosLector int
	);             
	 
	Select top 1 @IDPerfilUsuarioDefault = Valor from App.tblConfiguracionesGenerales with (nolock) where IDConfiguracion = 'IDPerfilDefaultEmpleados'    
	Select top 1 @IDUsuarioAdmin = Valor from App.tblConfiguracionesGenerales with (nolock) where IDConfiguracion = 'IDUsuarioAdmin'    
    
	select 
		 @IDLectorTrabajando		= L.IDLector
		,@AsignarTodosLosColaboradores = isnull(L.AsignarTodosLosColaboradores, 0)
	From Asistencia.tblLectores L with (nolock) 
	where (L.IDLector = @IDLector) OR (@IDLector = 0)  

	--select @AsignarTodosLosColaboradores

	if exists (
		select top 1 1 from Asistencia.tblGrupoFiltrosLector with (nolock) where IDLector = @IDLectorTrabajando
	)
	BEGIN
		select @i=min(IDGrupoFiltrosLector) from Asistencia.tblGrupoFiltrosLector with (nolock) where IDLector = @IDLector
		print @i
		
		if exists(
		Select top 1 1
		FROM Asistencia.tblGrupoFiltrosLector cfu2 with (nolock)
				join Asistencia.tblFiltrosLector fu2 with (nolock) on cfu2.IDGrupoFiltrosLector = fu2.IDGrupoFiltrosLector
			where cfu2.IDGrupoFiltrosLector = @i
			and (fu2.Filtro <> 'Excluir Empleado' ))
		BEGIN
			while exists(select top 1 1 from Asistencia.tblGrupoFiltrosLector with (nolock) where IDLector = @IDLector and IDGrupoFiltrosLector >= @i )
			begin
				delete from @dtFiltros
				delete from @dtFiltrosEmpleados
				delete from @empleados						

				select @Grupo = cfu.Nombre
				from Asistencia.tblGrupoFiltrosLector cfu with (nolock)
					join Asistencia.tblFiltrosLector fu with (nolock) on cfu.IDGrupoFiltrosLector = fu.IDGrupoFiltrosLector
				where cfu.IDGrupoFiltrosLector = @i
			
				--select @Grupo as GRUPO

				insert into @dtFiltros(Catalogo,Value)
				SELECT Filtro, 
				 STUFF(
					(SELECT ', '  + fu.ID
						FROM Asistencia.tblGrupoFiltrosLector cfu with (nolock)
						join Asistencia.tblFiltrosLector fu with (nolock) on cfu.IDGrupoFiltrosLector = fu.IDGrupoFiltrosLector  and fu.Filtro = fu2.Filtro
						where cfu.IDGrupoFiltrosLector = @i
					FOR XML PATH('')),
					1, 2, '') As [Value]
				FROM Asistencia.tblGrupoFiltrosLector cfu2 with (nolock)
					join Asistencia.tblFiltrosLector fu2 with (nolock) on cfu2.IDGrupoFiltrosLector = fu2.IDGrupoFiltrosLector
				where cfu2.IDGrupoFiltrosLector = @i
				and (fu2.Filtro <> 'Empleados' and fu2.Filtro <> 'Excluir Empleado' )
				group by Filtro

				--SELECT * from @dtFiltros

				insert into @dtFiltrosEmpleados(Catalogo,Value)
				SELECT Filtro, 
				 STUFF(
					(SELECT ', '  + fu.ID
						FROM Asistencia.tblGrupoFiltrosLector cfu with (nolock)
						join Asistencia.tblFiltrosLector  fu with (nolock) on cfu.IDGrupoFiltrosLector = fu.IDGrupoFiltrosLector  and fu.Filtro = fu2.Filtro
						where cfu.IDGrupoFiltrosLector = @i
					FOR XML PATH('')),
					1, 2, '') As [Value]
				FROM Asistencia.tblGrupoFiltrosLector cfu2 with (nolock)
					join Asistencia.tblFiltrosLector fu2 with (nolock) on cfu2.IDGrupoFiltrosLector = fu2.IDGrupoFiltrosLector
				where cfu2.IDGrupoFiltrosLector = @i
				and (fu2.Filtro = 'Empleados' and fu2.Filtro <> 'Excluir Empleado')
				group by Filtro

			
				--select * from @dtFiltrosEmpleados

				if ((isnull(@IDTipoNomina,0) = 0) and exists(select top 1 1 from @dtFiltros where Catalogo= 'TiposNomina'))
				begin
					select top 1 @IDTipoNomina = cast(item as int)
					from App.Split((select Value from @dtFiltros where Catalogo= 'TiposNomina'), ',')
				end else
				begin
					select @IDTipoNomina = 0
				end;
				
				insert into @empleados(IDEmpleado,ClaveEmpleado,Paterno,Materno,SegundoNombre,Nombre,NOMBRECOMPLETO,IDTipoNomina,IDDepartamento,IDSucursal,IDPuesto,IDTipoPrestacion,IDCliente,IDTipoContrato,IdEmpresa,IDRegPatronal,IDDivision,IDClasificacionCorporativa,IDCentroCosto,IDArea,IDRegion)
				select e.IDEmpleado,ClaveEmpleado,Paterno,Materno,SegundoNombre,Nombre,NOMBRECOMPLETO,IDTipoNomina,IDDepartamento,IDSucursal,IDPuesto,IDTipoPrestacion,IDCliente,IDTipoContrato,IdEmpresa,IDRegPatronal,IDDivision,IDClasificacionCorporativa,IDCentroCosto,IDArea,IDRegion
				from @empleados2 E
				where  ((E.IDTipoNomina = @IDTipoNomina) OR (@IDTipoNomina = 0))                
					and ((E.IDEmpleado in (Select item from App.Split((Select top 1 Value from @dtFiltrosEmpleados where Catalogo = 'Empleados'),','))               
						or (Not exists(Select 1 from @dtFiltrosEmpleados where Catalogo = 'Empleados' and isnull(Value,'')<>''))))              
					and ((E.IDDepartamento in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Departamentos'),','))               
						or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Departamentos' and isnull(Value,'')<>''))))              
					and ((E.IDSucursal in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Sucursales'),','))               
						or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Sucursales' and isnull(Value,'')<>''))))              
					and ((E.IDPuesto in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Puestos'),','))               
						or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Puestos' and isnull(Value,'')<>''))))              
					and ((E.IDTipoPrestacion in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Prestaciones'),',')))               
						or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Prestaciones' and isnull(Value,'')<>'')))           
					and ((E.IDCliente in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Clientes'),',')))               
						or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Clientes' and isnull(Value,'')<>'')))          
					and ((E.IDTipoContrato in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TiposContratacion'),',')))               
						or (Not exists(Select 1 from @dtFiltros where Catalogo = 'TiposContratacion' and isnull(Value,'')<>'')))        
					and ((E.IdEmpresa in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RazonesSociales'),',')))               
						or (Not exists(Select 1 from @dtFiltros where Catalogo = 'RazonesSociales' and isnull(Value,'')<>'')))        
					and ((E.IDRegPatronal in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RegPatronales'),',')))               
						or (Not exists(Select 1 from @dtFiltros where Catalogo = 'RegPatronales' and isnull(Value,'')<>'')))       
					and ((E.IDDivision in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Divisiones'),',')))               
						or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Divisiones' and isnull(Value,'')<>'')))    
					and ((E.IDCentroCosto in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'CentrosCostos'),',')))               
						or (Not exists(Select 1 from @dtFiltros where Catalogo = 'CentrosCostos' and isnull(Value,'')<>'')))   
					and ((E.IDArea in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Areas'),',')))               
						or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Areas' and isnull(Value,'')<>'')))
					and ((E.IDRegion in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Regiones'),',')))               
						or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Regiones' and isnull(Value,'')<>'')))   
					and ((E.IDClasificacionCorporativa in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClasificacionesCorporativas'),',')))               
						or (Not exists(Select 1 from @dtFiltros where Catalogo = 'ClasificacionesCorporativas' and isnull(Value,'')<>'')))      
					and ((              
					((COALESCE(E.ClaveEmpleado,'')+' '+ COALESCE(E.Paterno,'')+' '+COALESCE(E.Materno,'')+', '+COALESCE(E.Nombre,'')+' '+COALESCE(E.SegundoNombre,'')) like '%'+(Select top 1 Value from @dtFiltros where Catalogo = 'NombreClaveFilter')+'%')                
						) or (Not exists(Select 1 from @dtFiltros where Catalogo = 'NombreClaveFilter' and isnull(Value,'')<>'')))                          

				insert into #tempFinalEmpleados(IDLector,IDEmpleado,TipoFiltro,ValorFiltro,IDGrupoFiltrosLector)            
				select @IDLectorTrabajando,IDEmpleado,'Empleados' , 'Empleados | '+ NOMBRECOMPLETO,@i       
				from @empleados          
				WHERE IDEmpleado not in (Select IDEmpleado from #tempFinalEmpleados)            
            
				select @i=min(IDGrupoFiltrosLector) from Asistencia.tblGrupoFiltrosLector where IDLector = @IDLectorTrabajando and IDGrupoFiltrosLector > @i
			end;
		END
	END 

	IF (isnull(@AsignarTodosLosColaboradores, 0) = 1)   
	BEGIN            
		insert into #tempFinalEmpleados(IDLector,IDEmpleado,TipoFiltro, ValorFiltro,IDGrupoFiltrosLector)            
		select  @IDLectorTrabajando,IDEmpleado,'Empleados' , 'Empleados | '+ NOMBRECOMPLETO,@i          
		from @empleados2
		WHERE IDEmpleado not in (Select IDEmpleado from #tempFinalEmpleados)             
	END  

	select * , Row_Number()Over(Partition by IDEmpleado order by IDEmpleado) as RN 
	into #tempFinalEmpleadosLimpios
	from #tempFinalEmpleados

	delete #tempFinalEmpleadosLimpios
	where RN > 1

	/*ELIMINAR COLABORADORES DE LECTOR EMPLEADO, AMDS, LECTOR*/
	if(isjson(@Configuracion) > 0 and (json_value(@Configuracion, '$.connectivity') = 'ADMS'))
	BEGIN
		Declare @tblEmpleadosEliminar as table(
			IDEmpleado int
		)

		insert into @tblEmpleadosEliminar
		select tempFinalEmps.IDEmpleado
		from #tempFinalEmpleadosLimpios tempFinalEmps
			join Asistencia.tblFiltrosLector f with (nolock) on tempFinalEmps.IDEmpleado = cast(f.ID as int)
		where f.IDLector = @IDLectorTrabajando and f.Filtro = 'Excluir Empleado'

		delete tempFinalEmps
		from #tempFinalEmpleadosLimpios tempFinalEmps
			join Asistencia.tblFiltrosLector f with (nolock) on tempFinalEmps.IDEmpleado = cast(f.ID as int)
		where f.IDLector = @IDLectorTrabajando and f.Filtro = 'Excluir Empleado'

		--select * from #tempFinalEmpleadosLimpios

	
		insert into @tblEmpleadosEliminar
		select Target.IDEmpleado
		from Asistencia.tblLectoresEmpleados [TARGET]
			left join #tempFinalEmpleadosLimpios [SOURCE] on
				[TARGET].IDLector = [SOURCE].IDLector                   
				and [TARGET].IDEmpleado = [SOURCE].IDEmpleado                  
				and [TARGET].Filtro = [SOURCE].TipoFiltro                  
				and [TARGET].ValorFiltro = [SOURCE].ValorFiltro                  
				and [TARGET].IDGrupoFiltrosLector = [SOURCE].IDGrupoFiltrosLector
		where [TARGET].IDLector = @IDLectorTrabajando and ISNULL([SOURCE].IDEmpleado,0) = 0


		--DECLARE @MinID int,
		--		@MAXID int;
		--select @MinID = MIN(IDEmpleado),@MAXID = MAX(IDEmpleado) from @tblEmpleadosEliminar

		--WHILE (@MinID <= @MAXID)
		--BEGIN
		--	EXEC [zkteco].[spCoreCommand_DeleteUser] @DevSN = @DevSN, @IDEmpleado = @MinID, @IDUsuario = @IDUsuarioLogin
		--	EXEC [zkteco].[spCoreBorrarUserInfo] @DevSN = @DevSN, @IDEmpleado = @MinID, @IDUsuario = @IDUsuarioLogin
		--	SELECT @MinID = MIN(IDEmpleado) from @tblEmpleadosEliminar where IDEmpleado > @MinID
		--END
	END
	
	RAISERROR ('delete' , 0, 1) WITH NOWAIT
	DELETE [TARGET]
	from Asistencia.tblLectoresEmpleados [TARGET]
	join #tempFinalEmpleadosLimpios [SOURCE] on
		[TARGET].IDLector = [SOURCE].IDLector                   
		and [TARGET].IDEmpleado = [SOURCE].IDEmpleado                  
		and [TARGET].Filtro = [SOURCE].TipoFiltro                  
		and [TARGET].ValorFiltro = [SOURCE].ValorFiltro                  
		and [TARGET].IDGrupoFiltrosLector = [SOURCE].IDGrupoFiltrosLector
	where [TARGET].IDLector = @IDLectorTrabajando and ISNULL([SOURCE].IDEmpleado,0) <> 0

	RAISERROR ('update' , 0, 1) WITH NOWAIT
	update [TARGET]
		set [TARGET].IDLector				= [SOURCE].IDLector                  
			,[TARGET].IDEmpleado			= [SOURCE].IDEmpleado                  
			,[TARGET].Filtro				= [SOURCE].TipoFiltro                  
			,[TARGET].ValorFiltro			= [SOURCE].ValorFiltro                  
			,[TARGET].IDGrupoFiltrosLector	= [SOURCE].IDGrupoFiltrosLector                  
				
	from Asistencia.tblLectoresEmpleados [TARGET]
		join #tempFinalEmpleadosLimpios [SOURCE] on
			[TARGET].IDLector = [SOURCE].IDLector                   
			and [TARGET].IDEmpleado = [SOURCE].IDEmpleado                  
			and [TARGET].Filtro = [SOURCE].TipoFiltro                  
			and [TARGET].ValorFiltro = [SOURCE].ValorFiltro                  
			and [TARGET].IDGrupoFiltrosLector = [SOURCE].IDGrupoFiltrosLector
	where [TARGET].IDLector = @IDLectorTrabajando and ISNULL([SOURCE].IDEmpleado,0) <> 0

	RAISERROR ('Insert' , 0, 1) WITH NOWAIT
	INSERT Asistencia.tblLectoresEmpleados(IDLector,IDEmpleado,Filtro,ValorFiltro,IDGrupoFiltrosLector)            
	select   [TARGET].IDLector
			,[TARGET].IDEmpleado
			,[TARGET].TipoFiltro
			,[TARGET].ValorFiltro
			,[TARGET].IDGrupoFiltrosLector
	from #tempFinalEmpleadosLimpios [TARGET]
		left join Asistencia.tblLectoresEmpleados [SOURCE] on
			[TARGET].IDLector = [SOURCE].IDLector                   
			and [TARGET].IDEmpleado = [SOURCE].IDEmpleado                  
			and [TARGET].TipoFiltro = [SOURCE].Filtro                  
			and [TARGET].ValorFiltro = [SOURCE].ValorFiltro                  
			and [TARGET].IDGrupoFiltrosLector = [SOURCE].IDGrupoFiltrosLector
	where [TARGET].IDLector = @IDLectorTrabajando and [SOURCE].IDEmpleado IS  NULL
		and [TARGET].IDEmpleado NOT IN (
			SELECT IDEmpleado FROM Asistencia.tblLectoresEmpleados WITH(NOLOCK)
			WHERE IDLector = @IDLectorTrabajando 
		)

	--if(isjson(@Configuracion) > 0 and (json_value(@Configuracion, '$.connectivity') = 'ADMS'))
	--BEGIN
	--	DECLARE 	@tempUsers [zkteco].[dtUserInfo]

	--	INSERT INTO @tempUsers
	--	EXEC [zkteco].[spCoreBuscarEmpleadosMasterByLector] @DevSN = @DevSN, @IDUsuario = 1

	--	EXEC zkteco.spCoreCommand_UpdateUserInfo	@dtUserInfo = @tempUsers,	@DevSN = @DevSN,@ExecSchedulerQueryUsers = 0,	@IDUsuario = @IDUsuarioLogin
	--	EXEC zkteco.spCoreCommand_UpdateFaceTmp		@dtUserInfo = @tempUsers,	@DevSN = @DevSN,@ExecSchedulerQueryUsers = 0,	@IDUsuario = @IDUsuarioLogin
	--	EXEC zkteco.spCoreCommand_UpdateFingerTmp	@dtUserInfo = @tempUsers,	@DevSN = @DevSN,@ExecSchedulerQueryUsers = 0,	@IDUsuario = @IDUsuarioLogin
	--	EXEC zkteco.spCoreCommand_UpdateBioPhoto	@dtUserInfo = @tempUsers,	@DevSN = @DevSN,@ExecSchedulerQueryUsers = 0,	@IDUsuario = @IDUsuarioLogin
	--	EXEC zkteco.spCoreCommand_UpdateUserPic		@dtUserInfo = @tempUsers,	@DevSN = @DevSN,@ExecSchedulerQueryUsers = 0,	@IDUsuario = @IDUsuarioLogin

	--	EXEC zkteco.spCoreCreateSchedulerQueryUsersDataZKTECO @DevSN = @DevSN,  @dtUserInfo = @tempUsers, @IDUsuario = @IDUsuarioLogin
	--END
	
	drop table #tempFinalEmpleados;
GO
