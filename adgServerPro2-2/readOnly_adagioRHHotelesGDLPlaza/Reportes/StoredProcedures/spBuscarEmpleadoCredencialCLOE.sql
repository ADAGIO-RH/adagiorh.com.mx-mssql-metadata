USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spBuscarEmpleadoCredencialCLOE] --20340      
(      
	@ClaveEmpleadoInicial Varchar(20) = '0',    
	@ClaveEmpleadoFinal Varchar(20) = 'ZZZZZZZZZZZZZZZZZZZZ',        
	@Departamentos Varchar(max) = '',
	@Sucursales Varchar(max) = '',
	@Puestos Varchar(max) = '',
	@RazonesSociales Varchar(max) = '',
	@RegPatronales Varchar(max) = '',
	@Divisiones Varchar(max) = '',
	@Prestaciones Varchar(max) = '',
	@Detalle bit = 0,
	@IDUsuario int = null     
)      
AS      
BEGIN     

Declare @dtFiltros [Nomina].[dtFiltrosRH],    
	    @empleados [RH].[dtEmpleados],
		@IDDatoExtra_NOMBRE_GAFETE int;


	insert into @dtFiltros(Catalogo,Value)
	values('Departamentos',@Departamentos)
		,('Sucursales',@Sucursales)
		,('Puestos',@Puestos)
		,('RazonesSociales',@RazonesSociales)
		,('RegPatronales',@RegPatronales)
		,('Divisiones',@Divisiones)
		,('Prestaciones',@Prestaciones)
    
	SET @ClaveEmpleadoInicial = CASE WHEN ISNULL(@ClaveEmpleadoInicial,'') = '' THEN '0' ELSE  @ClaveEmpleadoInicial END
	SET @ClaveEmpleadoFinal = CASE WHEN ISNULL(@ClaveEmpleadoFinal,'') = '' THEN 'ZZZZZZZZZZZZZZZZZZZZ' ELSE  @ClaveEmpleadoFinal END 


	select @IDDatoExtra_NOMBRE_GAFETE = IDDatoExtra from [RH].[tblCatDatosExtra] where Nombre = 'NOMBRE_GAFETE'



	IF (@ClaveEmpleadoInicial like '%,%' or @ClaveEmpleadoFinal like '%,%')
	BEGIN 
       insert into @empleados    
		Exec [RH].[spBuscarEmpleados] @dtFiltros = @dtFiltros , @IDUsuario = @IDUsuario

		SELECT         
		em.IDEmpleado        
		,em.ClaveEmpleado        
		,em.NOMBRECOMPLETO
		,CASE
			WHEN dex.Valor IS NULL THEN em.Nombre
			ELSE dex.Valor 
		 END AS Nombre
		,em.SegundoNombre 
		,em.Nombre as PrimerNombre
		,ISNULL(em.Nombre,'') + ' ' + ISNULL(em.SegundoNombre,'') AS Nombres  
		,em.Paterno        
		,em.Materno  
		,ISNULL(em.Paterno,'') + ' ' + ISNULL(em.Materno,'') AS Apellidos        
		,em.Puesto        
		,em.Departamento        
		,em.Sucursal        
		,em.IMSS      
		,em.RFC      
		,em.CURP     
		,em.Empresa     
		,FBE.NombreCompleto NombreEmergencia
		,em.RegPatronal     
		,ISNULL(FBE.TelefonoCelular,ISNULL(FBE.TelefonoMovil,'')) Telefono      
		,CASE WHEN SE.TipoSangre IS NULL THEN '' ELSE ('TIPO DE SANGRE: '+SE.TipoSangre) END AS TipoSangre
		,case when FT.ClaveEmpleado IS NULL then (REPLACE(cg.Valor,'Empleados/','nofoto.jpg'))
		else (cg.Valor + em.ClaveEmpleado+'.jpg') END AS Foto
	FROM @empleados em  
		inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios FEU
			on EM.IDEmpleado = FEU.IDEmpleado
			and FEU.IDUsuario = @IDUsuario  
	--inner join [IMSS].[TblVigenciaEmpleado] V ON V.IDEmpleado = em.idempleado --Agregado solo para que jale los empleados vigentes
	--and V.FechaBaja is null and V.FechaReingreso is null
	left join RH.tblSaludEmpleado SE on EM.IDEmpleado = SE.IDEmpleado
	left join RH.tblFotosEmpleados FT on EM.IDEmpleado = FT.IDEmpleado
	left join RH.TblFamiliaresBenificiariosEmpleados FBE      
		on FBE.IDEmpleado = EM.IDEmpleado      
		and FBE.Emergencia = 1      
		Cross Apply App.tblConfiguracionesGenerales cg 
		inner join [App].[Split](@ClaveEmpleadoFinal,',')fti on fti.item = em.ClaveEmpleado
		inner join [App].[Split](@ClaveEmpleadoInicial,',') ftf on ftf.item = em.ClaveEmpleado
		left join [RH].[tblDatosExtraEmpleados] dex on em.IDEmpleado = dex.IDEmpleado and IDDatoExtra = @IDDatoExtra_NOMBRE_GAFETE

	where --EM.IDEmpleado between @IDEmpleadoIni and @IDEmpleadoFIN     and
		cg.IDConfiguracion = 'PathFotos'
		

	
	END
	ELSE 
	BEGIN 
       insert into @empleados    
		Exec [RH].[spBuscarEmpleados] @EmpleadoIni = @ClaveEmpleadoInicial,@EmpleadoFin = @ClaveEmpleadoFinal,@dtFiltros = @dtFiltros , @IDUsuario = @IDUsuario
		
		SELECT         
		em.IDEmpleado        
		,em.ClaveEmpleado        
		,em.NOMBRECOMPLETO        
		,CASE
			WHEN dex.Valor IS NULL THEN em.Nombre
			ELSE dex.Valor 
		 END AS Nombre
		,em.SegundoNombre 
		,em.Nombre as PrimerNombre     
		,ISNULL(em.Nombre,'') + ' ' + ISNULL(em.SegundoNombre,'') AS Nombres  
		,em.Paterno        
		,em.Materno  
		,ISNULL(em.Paterno,'') + ' ' + ISNULL(em.Materno,'') AS Apellidos        
		,em.Puesto        
		,em.Departamento        
		,em.Sucursal        
		,em.IMSS      
		,em.RFC      
		,em.CURP     
		,em.Empresa     
		,FBE.NombreCompleto NombreEmergencia
		,em.RegPatronal     
		,ISNULL(FBE.TelefonoCelular,ISNULL(FBE.TelefonoMovil,'')) Telefono      
		,CASE WHEN SE.TipoSangre IS NULL THEN '' ELSE ('TIPO DE SANGRE: '+SE.TipoSangre) END AS TipoSangre
		,case when FT.ClaveEmpleado IS NULL then (REPLACE(cg.Valor,'Empleados/','nofoto.jpg'))
		else (cg.Valor + em.ClaveEmpleado+'.jpg') END AS Foto
	FROM @empleados em  
		inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios FEU
			on EM.IDEmpleado = FEU.IDEmpleado
			and FEU.IDUsuario = @IDUsuario  
	--inner join [IMSS].[TblVigenciaEmpleado] V ON V.IDEmpleado = em.idempleado --Agregado solo para que jale los empleados vigentes
	--and V.FechaBaja is null and V.FechaReingreso is null
	left join RH.tblSaludEmpleado SE on EM.IDEmpleado = SE.IDEmpleado
	left join RH.tblFotosEmpleados FT on EM.IDEmpleado = FT.IDEmpleado
	left join RH.TblFamiliaresBenificiariosEmpleados FBE      
		on FBE.IDEmpleado = EM.IDEmpleado      
		and FBE.Emergencia = 1      
		Cross Apply App.tblConfiguracionesGenerales cg      
				left join [RH].[tblDatosExtraEmpleados] dex on em.IDEmpleado = dex.IDEmpleado and IDDatoExtra = @IDDatoExtra_NOMBRE_GAFETE

	where --EM.IDEmpleado between @IDEmpleadoIni and @IDEmpleadoFIN     and
		cg.IDConfiguracion = 'PathFotos';

	END

   
END
GO
