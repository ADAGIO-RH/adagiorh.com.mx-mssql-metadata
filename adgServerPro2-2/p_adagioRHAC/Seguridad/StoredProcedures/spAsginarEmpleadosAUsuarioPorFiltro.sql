USE [p_adagioRHAC]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [Seguridad].[spAsginarEmpleadosAUsuarioPorFiltro](              
	@IDUsuario int = 0             
	,@IDUsuarioLogin int  
	,@dtEmpleadosMaster [RH].[dtEmpleados] readonly            
) as              

--declare 
--	@IDUsuario int = 49            
--	,@IDUsuarioLogin int = 1     
	declare               
		@dtFiltros [Nomina].[dtFiltrosRH]               
		,@dtFiltrosEmpleados [Nomina].[dtFiltrosRH]               
		,@empleados [RH].[dtEmpleados]  
		,@empleados2 [RH].[dtEmpleados]  
    
		,@IDUsuarioTrabajando int            
		,@IDPerfilTrabajando int            
		,@IDEmpleadoTrabajando int       
		,@NombreCompletoTrabajando Varchar(255)    
		,@IDPerfilUsuarioDefault int   
		,@IDUsuarioAdmin int   
		,@i int = 0 
		,@Grupo varchar(255)
		,@IDTipoNomina int = 0
		,@soloVigentes bit = 0
		,@AsignarTodosLosColaboradores bit = 0
	;              

	declare @tblTempSubordinados table(    
		IDEmpleado int   
	);  

	if object_id('tempdb..#tempFinalEmpleados') is not null drop table #tempFinalEmpleados;              
	if object_id('tempdb..#tempFinalEmpleadosLimpios') is not null drop table #tempFinalEmpleadosLimpios;   
	 
	if not exists(select top 1 1 from @dtEmpleadosMaster)
	begin
		insert @empleados2(IDEmpleado,ClaveEmpleado,Paterno,Materno,SegundoNombre,Nombre,NOMBRECOMPLETO,IDTipoNomina,IDDepartamento,IDSucursal,IDPuesto,IDTipoPrestacion,IDCliente,IDTipoContrato,IdEmpresa,IDRegPatronal,IDDivision,IDClasificacionCorporativa,Vigente,IDCentroCosto,IDArea,IDRegion)
		select e.IDEmpleado,ClaveEmpleado,Paterno,Materno,SegundoNombre,Nombre,NOMBRECOMPLETO,IDTipoNomina,IDDepartamento,IDSucursal,IDPuesto,IDTipoPrestacion,IDCliente,IDTipoContrato,IdEmpresa,IDRegPatronal,IDDivision,IDClasificacionCorporativa,Vigente,IDCentroCosto,IDArea,IDRegion
		from RH.tblEmpleadosMaster e with (nolock)
			join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on e.IDEmpleado = dfe.IDEmpleado and dfe.IDUsuario = @IDUsuarioLogin
		--where isnull(e.Vigente,0) = 1
	end else
	begin
		insert @empleados2(IDEmpleado,ClaveEmpleado,Paterno,Materno,SegundoNombre,Nombre,NOMBRECOMPLETO,IDTipoNomina,IDDepartamento,IDSucursal,IDPuesto,IDTipoPrestacion,IDCliente,IDTipoContrato,IdEmpresa,IDRegPatronal,IDDivision,IDClasificacionCorporativa,Vigente,IDCentroCosto,IDArea,IDRegion)
		select IDEmpleado,ClaveEmpleado,Paterno,Materno,SegundoNombre,Nombre,NOMBRECOMPLETO,IDTipoNomina,IDDepartamento,IDSucursal,IDPuesto,IDTipoPrestacion,IDCliente,IDTipoContrato,IdEmpresa,IDRegPatronal,IDDivision,IDClasificacionCorporativa,Vigente,IDCentroCosto,IDArea,IDRegion
		from @dtEmpleadosMaster
	end;

	if exists(select top 1 1 from Seguridad.tblFiltrosUsuarios with (nolock) where IDUsuario = @IDUsuario and filtro = 'Solo Vigentes')
	BEGIN
		Delete @empleados2
		where Vigente = 0
	END
              
	create table #tempFinalEmpleados (  
		IDUsuario int  
		,IDEmpleado int  
		,TipoFiltro varchar(255) collate database_default  
		,ValorFiltro varchar(255) collate database_default  
		,IDCatFiltroUsuario int
	);             
	 
	Select top 1 @IDPerfilUsuarioDefault = Valor from App.tblConfiguracionesGenerales with (nolock) where IDConfiguracion = 'IDPerfilDefaultEmpleados'    
	Select top 1 @IDUsuarioAdmin = Valor from App.tblConfiguracionesGenerales with (nolock) where IDConfiguracion = 'IDUsuarioAdmin'    
            
	select 
		 @IDUsuarioTrabajando		= U.IDUsuario
		,@IDPerfilTrabajando		= U.IDPerfil
		,@IDEmpleadoTrabajando		= U.IDEmpleado
		,@NombreCompletoTrabajando	= e.NOMBRECOMPLETO   
		,@AsignarTodosLosColaboradores = isnull(p.AsignarTodosLosColaboradores, 0)
	From Seguridad.tblUsuarios U with (nolock) 
		join Seguridad.tblCatPerfiles p on p.IDPerfil = U.IDPerfil
		left join @empleados2 E on U.IDEmpleado = E.IDEmpleado           
	where (U.IDUsuario = @IDUsuario) OR (@IDUsuario = 0)            
            
	BEGIN-- SELF            
		insert into #tempFinalEmpleados(IDUsuario,IDEmpleado,TipoFiltro, ValorFiltro)            
		select @IDUsuarioTrabajando,IDEmpleado,'Empleados', 'Empleados | '+ NOMBRECOMPLETO            
		from @empleados2       
		where IDEmpleado = @IDEmpleadoTrabajando and IDEmpleado not in (Select IDEmpleado from #tempFinalEmpleados)            
	END-- SELF       
    
	BEGIN	--SUBORDINADOS      
		insert @tblTempSubordinados(IDEmpleado)
		select IDEmpleado             
		from RH.tblJefesEmpleados with (nolock)            
		where IDJefe = @IDEmpleadoTrabajando

		insert into #tempFinalEmpleados(IDUsuario,IDEmpleado,TipoFiltro,ValorFiltro)            
		select  @IDUsuarioTrabajando,e.IDEmpleado,'Subordinados','Subordinados | '+ e.NOMBRECOMPLETO              
		from @empleados2 e
			join @tblTempSubordinados s on s.IDEmpleado = e.IDEmpleado
		WHERE 
			--IDEmpleado in (            
			--	select IDEmpleado             
			--	from RH.tblJefesEmpleados with (nolock)            
			--	where IDJefe = @IDEmpleadoTrabajando
			--) and 
			e.IDEmpleado not in (Select IDEmpleado from #tempFinalEmpleados)            
	END	--SUBORDINADOS    
       
	if exists (
		select top 1 1 
		from Seguridad.tblCatFiltrosUsuarios cfu with (nolock) 
			join Seguridad.tblFiltrosUsuarios fu on fu.IDCatFiltroUsuario = cfu.IDCatFiltroUsuario
		where cfu.IDUsuario = @IDUsuarioTrabajando
			and fu.Filtro not in (
				'GruposHorarios'
				,'IncidenciasAusentismos'
				,'TiposMovAfiliatorios'
				,'TiposContratacion'
			)
	)
	BEGIN
		select @i=min(IDCatFiltroUsuario) from Seguridad.tblCatFiltrosUsuarios with (nolock) where IDUsuario = @IDUsuarioTrabajando
		print @i
		while exists(select top 1 1 from Seguridad.tblCatFiltrosUsuarios with (nolock) where IDUsuario = @IDUsuarioTrabajando and IDCatFiltroUsuario >= @i )
		begin
			delete from @dtFiltros
			delete from @dtFiltrosEmpleados
			delete from @empleados						

			select @Grupo = cfu.Nombre
			from Seguridad.tblCatFiltrosUsuarios cfu with (nolock)
				join Seguridad.tblFiltrosUsuarios fu with (nolock) on cfu.IDCatFiltroUsuario = fu.IDCatFiltroUsuario
			where cfu.IDCatFiltroUsuario = @i
 
			insert into @dtFiltros(Catalogo,Value)
			SELECT Filtro, 
			 STUFF(
				(SELECT ', '  + fu.ID
					FROM Seguridad.tblCatFiltrosUsuarios cfu with (nolock)
					join Seguridad.tblFiltrosUsuarios fu with (nolock) on cfu.IDCatFiltroUsuario = fu.IDCatFiltroUsuario  and fu.Filtro = fu2.Filtro
					where cfu.IDCatFiltroUsuario = @i
				FOR XML PATH('')),
				1, 2, '') As [Value]
			FROM Seguridad.tblCatFiltrosUsuarios cfu2 with (nolock)
				join Seguridad.tblFiltrosUsuarios fu2 with (nolock) on cfu2.IDCatFiltroUsuario = fu2.IDCatFiltroUsuario
			where cfu2.IDCatFiltroUsuario = @i
			and fu2.Filtro <> 'Empleados'
			group by Filtro

			insert into @dtFiltrosEmpleados(Catalogo,Value)
			SELECT Filtro, 
			 STUFF(
				(SELECT ', '  + fu.ID
					FROM Seguridad.tblCatFiltrosUsuarios cfu with (nolock)
					join Seguridad.tblFiltrosUsuarios  fu with (nolock) on cfu.IDCatFiltroUsuario = fu.IDCatFiltroUsuario  and fu.Filtro = fu2.Filtro
					where cfu.IDCatFiltroUsuario = @i
				FOR XML PATH('')),
				1, 2, '') As [Value]
			FROM Seguridad.tblCatFiltrosUsuarios cfu2 with (nolock)
				join Seguridad.tblFiltrosUsuarios fu2 with (nolock) on cfu2.IDCatFiltroUsuario = fu2.IDCatFiltroUsuario
			where cfu2.IDCatFiltroUsuario = @i
			and fu2.Filtro = 'Empleados'
			group by Filtro
			
			set @IDTipoNomina = 0

			if exists(select top 1 1 from @dtFiltros where Catalogo not in ('IncidenciasAusentismos','Solo Vigentes'))
			begin
				if ((isnull(@IDTipoNomina,0) = 0) and exists(select top 1 1 from @dtFiltros where Catalogo= 'TiposNomina'))
				begin
					--select @IDTipoNomina = cast(Value as int)
					--from @dtFiltros where Catalogo= 'TiposNomina'
					select top 1 @IDTipoNomina = cast(item as int)
					from App.Split((select Value from @dtFiltros where Catalogo= 'TiposNomina'), ',')
				end else
				begin
					select @IDTipoNomina = 0
				end;
				


				insert into @empleados(IDEmpleado,ClaveEmpleado,Paterno,Materno,SegundoNombre,Nombre,NOMBRECOMPLETO,IDTipoNomina,IDDepartamento,IDSucursal,IDPuesto,IDTipoPrestacion,IDCliente,IDTipoContrato,IdEmpresa,IDRegPatronal,IDDivision,IDClasificacionCorporativa,IDCentroCosto,IDArea,IDRegion)
				select e.IDEmpleado,ClaveEmpleado,Paterno,Materno,SegundoNombre,Nombre,NOMBRECOMPLETO,IDTipoNomina,IDDepartamento,IDSucursal,IDPuesto,IDTipoPrestacion,IDCliente,IDTipoContrato,IdEmpresa,IDRegPatronal,IDDivision,IDClasificacionCorporativa,IDCentroCosto,IDArea,IDRegion
				from @empleados2 E
				where 
				((E.IDTipoNomina = @IDTipoNomina) OR (@IDTipoNomina = 0))                
				   and ((E.IDEmpleado in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Empleados'),','))               
					   or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Empleados' and isnull(Value,'')<>''))))              
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
			end 


			set @IDTipoNomina = 0

			if exists(select top 1 1 from @dtFiltrosEmpleados  where Catalogo not in ('IncidenciasAusentismos','Solo Vigentes'))
			begin
				if ((isnull(@IDTipoNomina,0) = 0) and exists(select top 1 1 from @dtFiltrosEmpleados where Catalogo= 'TiposNomina'))
				begin
					--select @IDTipoNomina = cast(Value as int)
					--from @dtFiltrosEmpleados where Catalogo= 'TiposNomina'
					select top 1 @IDTipoNomina = cast(item as int)
					from App.Split((select Value from @dtFiltros where Catalogo= 'TiposNomina'), ',')
				end else
				begin
					select @IDTipoNomina = 0
				end;

				insert into @empleados(IDEmpleado,ClaveEmpleado,Paterno,Materno,SegundoNombre,Nombre,NOMBRECOMPLETO,IDTipoNomina,IDDepartamento,IDSucursal,IDPuesto,IDTipoPrestacion,IDCliente,IDTipoContrato,IdEmpresa,IDRegPatronal,IDDivision,IDClasificacionCorporativa)
				select e.IDEmpleado,ClaveEmpleado,Paterno,Materno,SegundoNombre,Nombre,NOMBRECOMPLETO,IDTipoNomina,IDDepartamento,IDSucursal,IDPuesto,IDTipoPrestacion,IDCliente,IDTipoContrato,IdEmpresa,IDRegPatronal,IDDivision,IDClasificacionCorporativa
				from @empleados2 E
				where 
				((E.IDTipoNomina = @IDTipoNomina) OR (@IDTipoNomina = 0))                
				   and ((E.IDEmpleado in (Select item from App.Split((Select top 1 Value from @dtFiltrosEmpleados where Catalogo = 'Empleados'),','))               
					   or (Not exists(Select 1 from @dtFiltrosEmpleados where Catalogo = 'Empleados' and isnull(Value,'')<>''))))              
				   and ((E.IDDepartamento in (Select item from App.Split((Select top 1 Value from @dtFiltrosEmpleados where Catalogo = 'Departamentos'),','))               
					   or (Not exists(Select 1 from @dtFiltrosEmpleados where Catalogo = 'Departamentos' and isnull(Value,'')<>''))))              
				   and ((E.IDSucursal in (Select item from App.Split((Select top 1 Value from @dtFiltrosEmpleados where Catalogo = 'Sucursales'),','))               
					  or (Not exists(Select 1 from @dtFiltrosEmpleados where Catalogo = 'Sucursales' and isnull(Value,'')<>''))))              
				   and ((E.IDPuesto in (Select item from App.Split((Select top 1 Value from @dtFiltrosEmpleados where Catalogo = 'Puestos'),','))               
					 or (Not exists(Select 1 from @dtFiltrosEmpleados where Catalogo = 'Puestos' and isnull(Value,'')<>''))))              
				   and ((E.IDTipoPrestacion in (Select item from App.Split((Select top 1 Value from @dtFiltrosEmpleados where Catalogo = 'Prestaciones'),',')))               
					 or (Not exists(Select 1 from @dtFiltrosEmpleados where Catalogo = 'Prestaciones' and isnull(Value,'')<>'')))           
				   and ((E.IDCliente in (Select item from App.Split((Select top 1 Value from @dtFiltrosEmpleados where Catalogo = 'Clientes'),',')))               
					 or (Not exists(Select 1 from @dtFiltrosEmpleados where Catalogo = 'Clientes' and isnull(Value,'')<>'')))          
				   and ((E.IDTipoContrato in (Select item from App.Split((Select top 1 Value from @dtFiltrosEmpleados where Catalogo = 'TiposContratacion'),',')))               
					 or (Not exists(Select 1 from @dtFiltrosEmpleados where Catalogo = 'TiposContratacion' and isnull(Value,'')<>'')))        
				   and ((E.IdEmpresa in (Select item from App.Split((Select top 1 Value from @dtFiltrosEmpleados where Catalogo = 'RazonesSociales'),',')))               
					 or (Not exists(Select 1 from @dtFiltrosEmpleados where Catalogo = 'RazonesSociales' and isnull(Value,'')<>'')))        
				 and ((E.IDRegPatronal in (Select item from App.Split((Select top 1 Value from @dtFiltrosEmpleados where Catalogo = 'RegPatronales'),',')))               
					 or (Not exists(Select 1 from @dtFiltrosEmpleados where Catalogo = 'RegPatronales' and isnull(Value,'')<>'')))       
				   and ((E.IDDivision in (Select item from App.Split((Select top 1 Value from @dtFiltrosEmpleados where Catalogo = 'Divisiones'),',')))               
					 or (Not exists(Select 1 from @dtFiltrosEmpleados where Catalogo = 'Divisiones' and isnull(Value,'')<>'')))   
				and ((E.IDCentroCosto in (Select item from App.Split((Select top 1 Value from @dtFiltrosEmpleados where Catalogo = 'CentrosCostos'),',')))               
					 or (Not exists(Select 1 from @dtFiltrosEmpleados where Catalogo = 'CentrosCostos' and isnull(Value,'')<>'')))   
				and ((E.IDArea in (Select item from App.Split((Select top 1 Value from @dtFiltrosEmpleados where Catalogo = 'Areas'),',')))               
					 or (Not exists(Select 1 from @dtFiltrosEmpleados where Catalogo = 'Areas' and isnull(Value,'')<>'')))  
                and ((E.IDRegion in (Select item from App.Split((Select top 1 Value from @dtFiltrosEmpleados where Catalogo = 'Regiones'),',')))               
					 or (Not exists(Select 1 from @dtFiltrosEmpleados where Catalogo = 'Regiones' and isnull(Value,'')<>''))) 	 
				 and ((E.IDClasificacionCorporativa in (Select item from App.Split((Select top 1 Value from @dtFiltrosEmpleados where Catalogo = 'ClasificacionesCorporativas'),',')))               
					 or (Not exists(Select 1 from @dtFiltrosEmpleados where Catalogo = 'ClasificacionesCorporativas' and isnull(Value,'')<>'')))      
				   and ((              
					((COALESCE(E.ClaveEmpleado,'')+' '+ COALESCE(E.Paterno,'')+' '+COALESCE(E.Materno,'')+', '+COALESCE(E.Nombre,'')+' '+COALESCE(E.SegundoNombre,'')) like '%'+(Select top 1 Value from @dtFiltrosEmpleados where Catalogo = 'NombreClaveFilter')+'%')                
						) or (Not exists(Select 1 from @dtFiltrosEmpleados where Catalogo = 'NombreClaveFilter' and isnull(Value,'')<>'')))                        
			end

			insert into #tempFinalEmpleados(IDUsuario,IDEmpleado,TipoFiltro,ValorFiltro,IDCatFiltroUsuario)            
			select @IDUsuarioTrabajando,IDEmpleado,'Empleados' , 'Empleados | '+ NOMBRECOMPLETO,@i       
			from @empleados          
			WHERE IDEmpleado not in (Select IDEmpleado from #tempFinalEmpleados)            
            
			--insert into #tempFinalEmpleados(IDUsuario,IDEmpleado,TipoFiltro,ValorFiltro,IDCatFiltroUsuario)            
			--select @IDUsuarioTrabajando,IDEmpleado,'Empleados' , 'Empleados | '+ NOMBRECOMPLETO,@i        
			--from @empleados2          
			--WHERE IDEmpleado not in (Select IDEmpleado from #tempFinalEmpleados)     

			select @i=min(IDCatFiltroUsuario) from Seguridad.tblCatFiltrosUsuarios where IDUsuario = @IDUsuarioTrabajando and IDCatFiltroUsuario > @i
		end;
	END 
	--ELSE IF (@IDPerfilTrabajando <> @IDPerfilUsuarioDefault)   
	ELSE IF (isnull(@AsignarTodosLosColaboradores, 0) = 1)   
	BEGIN            
		insert into #tempFinalEmpleados(IDUsuario,IDEmpleado,TipoFiltro, ValorFiltro,IDCatFiltroUsuario)            
		select  @IDUsuarioTrabajando,IDEmpleado,'Empleados' , 'Empleados | '+ NOMBRECOMPLETO,@i          
		from @empleados2
		WHERE IDEmpleado not in (Select IDEmpleado from #tempFinalEmpleados)             
	END      

	select * , Row_Number()Over(Partition by IDEmpleado order by IDUsuario) as RN 
	into #tempFinalEmpleadosLimpios
	from #tempFinalEmpleados

	delete #tempFinalEmpleadosLimpios
	where RN > 1

	delete tempFinalEmps
	from #tempFinalEmpleadosLimpios tempFinalEmps
		join Seguridad.tblFiltrosUsuarios f with (nolock) on tempFinalEmps.IDEmpleado = cast(f.ID as int)
	where f.IDUsuario = @IDUsuarioTrabajando and f.Filtro = 'Excluir Empleado'


	if (@IDUsuario <> 1)
	BEGIN
		--RAISERROR ('Delete' , 0, 1) WITH NOWAIT	

		delete [TARGET]
		from Seguridad.tblDetalleFiltrosEmpleadosUsuarios [TARGET]
			left join #tempFinalEmpleadosLimpios [SOURCE] on
					[TARGET].IDUsuario = [SOURCE].IDUsuario                   
				and [TARGET].IDEmpleado = [SOURCE].IDEmpleado                  
				--and [TARGET].Filtro = [SOURCE].TipoFiltro                  
				--and [TARGET].ValorFiltro = [SOURCE].ValorFiltro                  
				--and [TARGET].IDCatFiltroUsuario = [SOURCE].IDCatFiltroUsuario
		where [TARGET].IDUsuario = @IDUsuario and [SOURCE].IDEmpleado IS NULL
	
		RAISERROR ('update' , 0, 1) WITH NOWAIT
		update [TARGET]
			set [TARGET].IDUsuario				= [SOURCE].IDUsuario                  
				,[TARGET].IDEmpleado			= [SOURCE].IDEmpleado                  
				,[TARGET].Filtro				= [SOURCE].TipoFiltro                  
				,[TARGET].ValorFiltro			= [SOURCE].ValorFiltro                  
				,[TARGET].IDCatFiltroUsuario	= [SOURCE].IDCatFiltroUsuario                  
				
		from Seguridad.tblDetalleFiltrosEmpleadosUsuarios [TARGET]
			join #tempFinalEmpleadosLimpios [SOURCE] on
				[TARGET].IDUsuario = [SOURCE].IDUsuario                   
				and [TARGET].IDEmpleado = [SOURCE].IDEmpleado                  
				and [TARGET].Filtro = [SOURCE].TipoFiltro                  
				and [TARGET].ValorFiltro = [SOURCE].ValorFiltro                  
				and [TARGET].IDCatFiltroUsuario = [SOURCE].IDCatFiltroUsuario
		where [TARGET].IDUsuario = @IDUsuario and ISNULL([SOURCE].IDEmpleado,0) <> 0

		RAISERROR ('Insert' , 0, 1) WITH NOWAIT
		INSERT Seguridad.tblDetalleFiltrosEmpleadosUsuarios(IDUsuario,IDEmpleado,Filtro,ValorFiltro,IDCatFiltroUsuario)            
		select   [TARGET].IDUsuario
				,[TARGET].IDEmpleado
				,[TARGET].TipoFiltro
				,[TARGET].ValorFiltro
				,[TARGET].IDCatFiltroUsuario
		from #tempFinalEmpleadosLimpios [TARGET]
			left join Seguridad.tblDetalleFiltrosEmpleadosUsuarios [SOURCE] on
				[TARGET].IDUsuario = [SOURCE].IDUsuario                   
				and [TARGET].IDEmpleado = [SOURCE].IDEmpleado                  
				and [TARGET].TipoFiltro = [SOURCE].Filtro                  
				and [TARGET].ValorFiltro = [SOURCE].ValorFiltro                  
				and [TARGET].IDCatFiltroUsuario = [SOURCE].IDCatFiltroUsuario
		where [TARGET].IDUsuario = @IDUsuario and [SOURCE].IDEmpleado IS  NULL
			and [TARGET].IDEmpleado NOT IN (
				SELECT IDEmpleado FROM Seguridad.tblDetalleFiltrosEmpleadosUsuarios WITH(NOLOCK)
				WHERE IDUsuario = @IDUsuario
			)
	END
	ELSE
	BEGIN
		MERGE Seguridad.tblDetalleFiltrosEmpleadosUsuarios AS TARGET            
		USING RH.tblEmpleadosMaster AS SOURCE             
		ON (TARGET.IDUsuario = @IDUsuario)             
			AND (TARGET.IDEmpleado = SOURCE.IDEmpleado )            
			AND (TARGET.Filtro = 'Empleados')           
			AND (TARGET.ValorFiltro = 'Empleados | '+SOURCE.NOMBRECOMPLETO)           
			AND (TARGET.IDCatFiltroUsuario = 0) 
       
		--When records are matched, update the records if there is any change            
	WHEN MATCHED             
		THEN UPDATE             
		SET TARGET.IDUsuario			= @IDUsuario            
			,TARGET.IDEmpleado			= SOURCE.IDEmpleado            
			,TARGET.Filtro				= 'Empleados'         
			,TARGET.ValorFiltro			= 'Empleados | '+SOURCE.NOMBRECOMPLETO        
			,TARGET.IDCatFiltroUsuario	= 0        
              
	--When no records are matched, insert the incoming records from source table to target table            
	WHEN NOT MATCHED BY TARGET and SOURCE.IDEmpleado not in(Select IDEmpleado from Seguridad.tblDetalleFiltrosEmpleadosUsuarios where IDUsuario = @IDUsuario)                
		THEN INSERT (IDUsuario, IDEmpleado, Filtro,ValorFiltro,IDCatFiltroUsuario)             
		VALUES (@IDUsuario  , SOURCE.IDEmpleado, 'Empleados','Empleados | '+SOURCE.NOMBRECOMPLETO,0)            
	--When there is a row that exists in target and same record does not exist in source then delete this record target            
	;  
	END
	drop table #tempFinalEmpleados;
GO
