USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************     
** Descripción  : Actualiza la tabla Master de Empleados    
** Autor   : Aneudy Abreu    
** Email   : aneudy.abreu@adagio.com.mx    
** FechaCreacion : 2018-07-05    
** Paremetros  :                  
****************************************************************************************************    
HISTORIAL DE CAMBIOS    
Fecha(yyyy-mm-dd) Autor   Comentario    
------------------- ------------------- ------------------------------------------------------------    
0000-00-00  NombreCompleto  ¿Qué cambió?    
***************************************************************************************************/    
CREATE proc [RH].[spSincronizarEmpleadosMaster] (    
    @EmpleadoIni Varchar(20) = '0'    
    ,@EmpleadoFin Varchar(20) = 'zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz' )    
as    
    
    declare     
		@ListaEmpleados [RH].dtEmpleados
		,@IDUsuarioAdmin int
	;    
    
	select @IDUsuarioAdmin = cast(Valor as int) from App.tblConfiguracionesGenerales with (nolock) where IDConfiguracion = 'IDUsuarioAdmin'

    insert into @ListaEmpleados    
	exec [Seguridad].[spBuscarEmpleados] 
		   @EmpleadoIni = @EmpleadoIni    
          ,@EmpleadoFin = @EmpleadoFin   
		  ,@IDUsuario	= @IDUsuarioAdmin 
        
	BEGIN TRY    
		BEGIN TRAN TransaccionSincMasterEmpleados    
       
			MERGE [RH].[tblEmpleadosMaster] AS TARGET    
			USING @ListaEmpleados as SOURCE    
				on TARGET.IDEmpleado = SOURCE.IDEmpleado    
			WHEN MATCHED THEN    
				update     
				 set     
					 TARGET.ClaveEmpleado    = SOURCE.ClaveEmpleado       
					,TARGET.RFC      = SOURCE.RFC         
					,TARGET.CURP      = SOURCE.CURP         
					,TARGET.IMSS      = SOURCE.IMSS         
					,TARGET.Nombre      = SOURCE.Nombre         
					,TARGET.SegundoNombre    = SOURCE.SegundoNombre       
					,TARGET.Paterno      = SOURCE.Paterno         
					,TARGET.Materno      = SOURCE.Materno         
					,TARGET.NOMBRECOMPLETO    = SOURCE.NOMBRECOMPLETO       
					,TARGET.IDLocalidadNacimiento   = SOURCE.IDLocalidadNacimiento      
					,TARGET.LocalidadNacimiento   = SOURCE.LocalidadNacimiento      
					,TARGET.IDMunicipioNacimiento   = SOURCE.IDMunicipioNacimiento      
					,TARGET.MunicipioNacimiento   = SOURCE.MunicipioNacimiento      
					,TARGET.IDEstadoNacimiento   = SOURCE.IDEstadoNacimiento      
					,TARGET.EstadoNacimiento    = SOURCE.EstadoNacimiento       
					,TARGET.IDPaisNacimiento    = SOURCE.IDPaisNacimiento       
					,TARGET.PaisNacimiento    = SOURCE.PaisNacimiento       
					,TARGET.FechaNacimiento    = SOURCE.FechaNacimiento       
					,TARGET.IDEstadoCiviL    = SOURCE.IDEstadoCiviL       
					,TARGET.EstadoCivil     = SOURCE.EstadoCivil        
					,TARGET.Sexo      = SOURCE.Sexo         
					,TARGET.IDEscolaridad    = SOURCE.IDEscolaridad       
					,TARGET.Escolaridad     = SOURCE.Escolaridad        
					,TARGET.DescripcionEscolaridad   = SOURCE.DescripcionEscolaridad      
					,TARGET.IDInstitucion    = SOURCE.IDInstitucion       
					,TARGET.Institucion     = SOURCE.Institucion        
					,TARGET.IDProbatorio     = SOURCE.IDProbatorio        
					,TARGET.Probatorio     = SOURCE.Probatorio        
					,TARGET.FechaPrimerIngreso   = SOURCE.FechaPrimerIngreso      
					,TARGET.FechaIngreso     = SOURCE.FechaIngreso        
					,TARGET.FechaAntiguedad    = SOURCE.FechaAntiguedad       
					,TARGET.Sindicalizado    = SOURCE.Sindicalizado       
					,TARGET.IDJornadaLaboral    = SOURCE.IDJornadaLaboral       
					,TARGET.JornadaLaboral    = SOURCE.JornadaLaboral       
					,TARGET.UMF      = SOURCE.UMF         
					,TARGET.CuentaContable    = SOURCE.CuentaContable       
					,TARGET.IDTipoRegimen    = SOURCE.IDTipoRegimen       
					,TARGET.TipoRegimen     = SOURCE.TipoRegimen        
					,TARGET.IDPreferencia    = SOURCE.IDPreferencia       
					,TARGET.IDDepartamento    = SOURCE.IDDepartamento       
					,TARGET.Departamento     = SOURCE.Departamento        
					,TARGET.IDSucursal     = SOURCE.IDSucursal        
					,TARGET.Sucursal    = SOURCE.Sucursal        
					,TARGET.IDPuesto     = SOURCE.IDPuesto        
					,TARGET.Puesto      = SOURCE.Puesto         
					,TARGET.IDCliente     = SOURCE.IDCliente        
					,TARGET.Cliente      = SOURCE.Cliente         
					,TARGET.IDEmpresa     = SOURCE.IDEmpresa        
					,TARGET.Empresa      = SOURCE.Empresa         
					,TARGET.IDCentroCosto    = SOURCE.IDCentroCosto       
					,TARGET.CentroCosto     = SOURCE.CentroCosto        
					,TARGET.IDArea      = SOURCE.IDArea         
					,TARGET.Area      = SOURCE.Area         
					,TARGET.IDDivision     = SOURCE.IDDivision        
					,TARGET.Division     = SOURCE.Division        
					,TARGET.IDRegion     = SOURCE.IDRegion        
					,TARGET.Region      = SOURCE.Region         
					,TARGET.IDClasificacionCorporativa  = SOURCE.IDClasificacionCorporativa    
					,TARGET.ClasificacionCorporativa  = SOURCE.ClasificacionCorporativa     
					,TARGET.IDRegPatronal    = SOURCE.IDRegPatronal       
					,TARGET.RegPatronal     = SOURCE.RegPatronal        
					,TARGET.IDTipoNomina     = SOURCE.IDTipoNomina        
					,TARGET.TipoNomina     = SOURCE.TipoNomina        
					,TARGET.SalarioDiario    = SOURCE.SalarioDiario       
					,TARGET.SalarioDiarioReal    = SOURCE.SalarioDiarioReal       
					,TARGET.SalarioIntegrado    = SOURCE.SalarioIntegrado       
					,TARGET.SalarioVariable    = SOURCE.SalarioVariable       
					,TARGET.IDTipoPrestacion    = SOURCE.IDTipoPrestacion       
					,TARGET.IDRazonSocial    = SOURCE.IDRazonSocial       
					,TARGET.RazonSocial     = SOURCE.RazonSocial        
					,TARGET.IDAfore      = SOURCE.IDAfore         
					,TARGET.Afore      = SOURCE.Afore         
					,TARGET.Vigente      = SOURCE.Vigente    
					,TARGET.[ClaveNombreCompleto]          = cast (SOURCE.IDEmpleado as varchar) +' '+COALESCE(cast(SOURCE.ClaveEmpleado as nvarchar(max)),'')    
						+' '+ COALESCE(cast(SOURCE.Paterno as nvarchar(max)),'')    
						+' '+COALESCE(SOURCE.Materno,'')    
						+' '+COALESCE(SOURCE.Nombre,'')    
						+' '+COALESCE(SOURCE.SegundoNombre,'')  
					,TARGET.[PermiteChecar]  =   SOURCE.[PermiteChecar]  
					,TARGET.[RequiereChecar] =   SOURCE.[RequiereChecar]     
					,TARGET.[PagarTiempoExtra] =  SOURCE.[PagarTiempoExtra]    
					,TARGET.[PagarPrimaDominical] = SOURCE.[PagarPrimaDominical]   
					,TARGET.[PagarDescansoLaborado]= SOURCE.[PagarDescansoLaborado]   
					,TARGET.[PagarFestivoLaborado] = SOURCE.[PagarFestivoLaborado]  
					,TARGET.[IDDocumento]			= SOURCE.[IDDocumento]		
					,TARGET.[Documento]			= SOURCE.[Documento]		
					,TARGET.[IDTipoContrato]		= SOURCE.[IDTipoContrato]	
					,TARGET.[TipoContrato]		= SOURCE.[TipoContrato]	
					,TARGET.[FechaIniContrato]	= SOURCE.[FechaIniContrato]
					,TARGET.[FechaFinContrato]	= SOURCE.[FechaFinContrato]
					,TARGET.[TiposPrestacion]	= SOURCE.[TiposPrestacion]
					,TARGET.[TipoTrabajadorEmpleado]	= SOURCE.[TipoTrabajadorEmpleado]
					
			   WHEN NOT MATCHED BY TARGET THEN     
				INSERT(IDEmpleado,ClaveEmpleado,RFC,CURP,IMSS,Nombre,SegundoNombre,Paterno,Materno    
					,NOMBRECOMPLETO,IDLocalidadNacimiento,LocalidadNacimiento,IDMunicipioNacimiento,MunicipioNacimiento,IDEstadoNacimiento    
					,EstadoNacimiento,IDPaisNacimiento,PaisNacimiento,FechaNacimiento,IDEstadoCiviL,EstadoCivil,Sexo,IDEscolaridad,Escolaridad    
					,DescripcionEscolaridad,IDInstitucion,Institucion,IDProbatorio,Probatorio,FechaPrimerIngreso,FechaIngreso    
					,FechaAntiguedad,Sindicalizado,IDJornadaLaboral,JornadaLaboral,UMF,CuentaContable,IDTipoRegimen    
					,TipoRegimen,IDPreferencia,IDDepartamento,Departamento,IDSucursal,Sucursal,IDPuesto    
					,Puesto,IDCliente,Cliente,IDEmpresa,Empresa,IDCentroCosto,CentroCosto,IDArea    
					,Area,IDDivision,Division,IDRegion,Region,IDClasificacionCorporativa    
					,ClasificacionCorporativa,IDRegPatronal,RegPatronal,IDTipoNomina    
					,TipoNomina,SalarioDiario,SalarioDiarioReal,SalarioIntegrado,SalarioVariable    
					,IDTipoPrestacion,IDRazonSocial,RazonSocial,IDAfore,Afore,Vigente,[ClaveNombreCompleto]  
			  ,[PermiteChecar],[RequiereChecar],[PagarTiempoExtra],[PagarPrimaDominical],[PagarDescansoLaborado],[PagarFestivoLaborado]
			  ,[IDDocumento],[Documento],[IDTipoContrato],[TipoContrato],[FechaIniContrato],[FechaFinContrato]  
			  ,  [TiposPrestacion],[TipoTrabajadorEmpleado]
			  )
				values(SOURCE.IDEmpleado,SOURCE.ClaveEmpleado,SOURCE.RFC,SOURCE.CURP,SOURCE.IMSS    
					,SOURCE.Nombre,SOURCE.SegundoNombre,SOURCE.Paterno,SOURCE.Materno,SOURCE.NOMBRECOMPLETO,SOURCE.IDLocalidadNacimiento    
					,SOURCE.LocalidadNacimiento,SOURCE.IDMunicipioNacimiento,SOURCE.MunicipioNacimiento,SOURCE.IDEstadoNacimiento,SOURCE.EstadoNacimiento    
					,SOURCE.IDPaisNacimiento,SOURCE.PaisNacimiento,SOURCE.FechaNacimiento,SOURCE.IDEstadoCiviL,SOURCE.EstadoCivil,SOURCE.Sexo    
					,SOURCE.IDEscolaridad,SOURCE.Escolaridad,SOURCE.DescripcionEscolaridad,SOURCE.IDInstitucion,SOURCE.Institucion    
					,SOURCE.IDProbatorio,SOURCE.Probatorio,SOURCE.FechaPrimerIngreso,SOURCE.FechaIngreso,SOURCE.FechaAntiguedad,SOURCE.Sindicalizado    
					,SOURCE.IDJornadaLaboral,SOURCE.JornadaLaboral,SOURCE.UMF,SOURCE.CuentaContable,SOURCE.IDTipoRegimen,SOURCE.TipoRegimen    
					,SOURCE.IDPreferencia,SOURCE.IDDepartamento,SOURCE.Departamento,SOURCE.IDSucursal,SOURCE.Sucursal,SOURCE.IDPuesto    
					,SOURCE.Puesto,SOURCE.IDCliente,SOURCE.Cliente,SOURCE.IDEmpresa,SOURCE.Empresa,SOURCE.IDCentroCosto    
					,SOURCE.CentroCosto,SOURCE.IDArea,SOURCE.Area,SOURCE.IDDivision,SOURCE.Division,SOURCE.IDRegion,SOURCE.Region    
					,SOURCE.IDClasificacionCorporativa,SOURCE.ClasificacionCorporativa,SOURCE.IDRegPatronal,SOURCE.RegPatronal,SOURCE.IDTipoNomina    
					,SOURCE.TipoNomina,SOURCE.SalarioDiario,SOURCE.SalarioDiarioReal,SOURCE.SalarioIntegrado,SOURCE.SalarioVariable    
					,SOURCE.IDTipoPrestacion,SOURCE.IDRazonSocial,SOURCE.RazonSocial,SOURCE.IDAfore,SOURCE.Afore,SOURCE.Vigente    
					,cast (SOURCE.IDEmpleado as varchar) +' '+COALESCE(cast(SOURCE.ClaveEmpleado as nvarchar(max)),'')    
						+' '+ COALESCE(cast(SOURCE.Paterno as nvarchar(max)),'')    
						+' '+COALESCE(SOURCE.Materno,'')    
						+', '+COALESCE(SOURCE.Nombre,'')    
						+' '+COALESCE(SOURCE.SegundoNombre,'')   
					,SOURCE.[PermiteChecar]  
					,SOURCE.[RequiereChecar]     
					,SOURCE.[PagarTiempoExtra]    
					,SOURCE.[PagarPrimaDominical]   
					,SOURCE.[PagarDescansoLaborado]   
					,SOURCE.[PagarFestivoLaborado]
					,SOURCE.[IDDocumento],SOURCE.[Documento],SOURCE.[IDTipoContrato],SOURCE.[TipoContrato],SOURCE.[FechaIniContrato],SOURCE.[FechaFinContrato]  
					,SOURCE.[TiposPrestacion] 
					,SOURCE.[TipoTrabajadorEmpleado]
			   )    
			   WHEN NOT MATCHED BY SOURCE and TARGET.ClaveEmpleado between @EmpleadoIni and @EmpleadoFin THEN     
			   DELETE;    
			   --OUTPUT $action,     
			   --DELETED.*,        
			   --INSERTED.*;       
			   --SELECT @@ROWCOUNT;    
			COMMIT TRAN TransaccionSincMasterEmpleados    
	END TRY    
	BEGIN CATCH    
		ROLLBACK TRAN TransaccionSincMasterEmpleados    

		select ERROR_MESSAGE()
	END CATCH     
    
    update  RH.tblEmpleadosMaster    
    set Vigente = [RH].[fnFueVigente](IDEmpleado, getdate(), getdate())    
    where ClaveEmpleado between @EmpleadoIni and @EmpleadoFin
GO
