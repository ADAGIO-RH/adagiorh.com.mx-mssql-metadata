USE [p_adagioRHStark]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spBuscarEmpleadoCredencialSTARK] --20340      
(      
	@ClaveEmpleadoInicial Varchar(20) = '0',    
	@ClaveEmpleadoFinal Varchar(20) = 'ZZZZZZZZZZZZZZZZZZZZ',        
	@Departamentos Varchar(max) =null,
	@Sucursales Varchar(max) = null,
	@Puestos Varchar(max) = null,
	@IDUsuario int = 1  ,
    @Empleados Varchar(max)  =null
   
)      
AS      
BEGIN     

Declare @dtFiltros [Nomina].[dtFiltrosRH],
		@empleadostb [RH].[dtEmpleados];

	insert into @dtFiltros(Catalogo,Value)
	values('Departamentos',@Departamentos)
		,('Sucursales',@Sucursales)
		,('Puestos',@Puestos)
        ,('Empleados',@Empleados)

	SET @ClaveEmpleadoInicial = CASE WHEN ISNULL(@ClaveEmpleadoInicial,'') = '' THEN '0' ELSE  @ClaveEmpleadoInicial END
	SET @ClaveEmpleadoFinal = CASE WHEN ISNULL(@ClaveEmpleadoFinal,'') = '' THEN 'ZZZZZZZZZZZZZZZZZZZZ' ELSE  @ClaveEmpleadoFinal END 

--	select @IDDatoExtra_NOMBRE_GAFETE = IDDatoExtra from [RH].[tblCatDatosExtra] where Nombre = 'NOMBRE_GAFETE'

	IF (@ClaveEmpleadoInicial like '%,%' or @ClaveEmpleadoFinal like '%,%')
	BEGIN 
       insert into @empleadostb    
		Exec [RH].[spBuscarEmpleados] @dtFiltros = @dtFiltros , @IDUsuario = @IDUsuario

	SELECT         
		 dtEmp.IDEmpleado        
		,dtEmp.ClaveEmpleado        
		,dtEmp.NOMBRECOMPLETO
		,dtEmp.Nombre AS PrimerNombre
		--,em.SegundoNombre 
		--,em.Nombre as PrimerNombre
		,ISNULL(dtEmp.Nombre,'') + ' ' + ISNULL(dtEmp.SegundoNombre,'') AS Nombres  
		,dtEmp.Paterno        
		,dtEmp.Materno  
		,ISNULL(dtEmp.Paterno,'') + ' ' + ISNULL(dtEmp.Materno,'') AS Apellidos        
		,dtEmp.Puesto        
		,dtEmp.Departamento        
		,dtEmp.Sucursal        
		,dtEmp.IMSS      
        ,em.Vigente
		,dtEmp.RFC      
		,dtEmp.CURP         
		,dtEmp.RegPatronal     
		,dtEmp.Empresa AS Empresa
        ,reg.RegistroPatronal
		,FBE.NombreCompleto NombreEmergencia
		,ISNULL(FBE.TelefonoCelular,ISNULL(FBE.TelefonoMovil,'')) Telefono      
		,CASE WHEN SE.TipoSangre IS NULL THEN '' ELSE ('TIPO DE SANGRE: '+SE.TipoSangre) END AS TipoSangre
		,SE.Alergias
		,SE.TratamientoAlergias
		,case when FT.ClaveEmpleado IS NULL then (REPLACE(cg.Valor,'Empleados/','nofoto.jpg'))
		else (cg.Valor + dtEmp.ClaveEmpleado+'.jpg') END AS Foto
	FROM @empleadostb dtEmp  
        left join RH.tblCatRegPatronal reg on reg.IDRegPatronal = dtEmp.IDRegPatronal
        inner join RH.tblEmpleadosMaster em on em.IDEmpleado =dtEmp.IDEmpleado
		inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios FEU on dtEmp.IDEmpleado = FEU.IDEmpleado
		and FEU.IDUsuario = @IDUsuario  
		--inner join [IMSS].[TblVigenciaEmpleado] V ON V.IDEmpleado = em.idempleado --Agregado solo para que jale los empleados vigentes
		--and V.FechaBaja is null and V.FechaReingreso is null
		left join RH.tblSaludEmpleado SE on dtEmp.IDEmpleado = SE.IDEmpleado
		left join RH.tblFotosEmpleados FT on dtEmp.IDEmpleado = FT.IDEmpleado
		left join RH.TblFamiliaresBenificiariosEmpleados FBE      
		on FBE.IDEmpleado = dtEmp.IDEmpleado      
		and FBE.Emergencia = 1      
		Cross Apply App.tblConfiguracionesGenerales cg 
		inner join [App].[Split](@ClaveEmpleadoFinal,',')fti on fti.item = dtEmp.ClaveEmpleado
		inner join [App].[Split](@ClaveEmpleadoInicial,',') ftf on ftf.item = dtEmp.ClaveEmpleado
	--	left join [RH].[tblDatosExtraEmpleados] dex on em.IDEmpleado = dex.IDEmpleado and IDDatoExtra = @IDDatoExtra_NOMBRE_GAFETE
	where --EM.IDEmpleado between @IDEmpleadoIni and @IDEmpleadoFIN     and
		cg.IDConfiguracion = 'PathFotos' and em.Vigente in (0,1)	
	END
ELSE 
	BEGIN 
       insert into @empleadostb    
		Exec [RH].[spBuscarEmpleados] @EmpleadoIni = @ClaveEmpleadoInicial,@EmpleadoFin = @ClaveEmpleadoFinal,@dtFiltros = @dtFiltros , @IDUsuario = @IDUsuario
		
		SELECT         
		em.IDEmpleado        
		,em.ClaveEmpleado        
		,em.NOMBRECOMPLETO        
		,em.Nombre AS PrimerNombre
		--,em.SegundoNombre 
		--,em.Nombre as PrimerNombre     
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
        ,mm.Vigente
		,em.Empresa     
		,FBE.NombreCompleto NombreEmergencia
		,em.RegPatronal     
        ,reg.RegistroPatronal
		,SE.Alergias
		,SE.TratamientoAlergias
		,ISNULL(FBE.TelefonoCelular,ISNULL(FBE.TelefonoMovil,'')) Telefono      
		,CASE WHEN SE.TipoSangre IS NULL THEN '' ELSE ('TIPO DE SANGRE: '+SE.TipoSangre) END AS TipoSangre
		,case when FT.ClaveEmpleado IS NULL then (REPLACE(cg.Valor,'Empleados/','nofoto.jpg'))
		else (cg.Valor + em.ClaveEmpleado+'.jpg') END AS Foto
	FROM @empleadostb em  
		 left join RH.tblCatRegPatronal reg on reg.IDRegPatronal = em.IDRegPatronal
		 inner join RH.tblEmpleadosMaster mm on mm.IDEmpleado =em.IDEmpleado
		 inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios FEU on EM.IDEmpleado = FEU.IDEmpleado
		 and FEU.IDUsuario = @IDUsuario  
		--inner join [IMSS].[TblVigenciaEmpleado] V ON V.IDEmpleado = em.idempleado --Agregado solo para que jale los empleados vigentes
		--and V.FechaBaja is null and V.FechaReingreso is null
		left join RH.tblSaludEmpleado SE on EM.IDEmpleado = SE.IDEmpleado
		left join RH.tblFotosEmpleados FT on EM.IDEmpleado = FT.IDEmpleado
		left join RH.TblFamiliaresBenificiariosEmpleados FBE      
		on FBE.IDEmpleado = EM.IDEmpleado      
		and FBE.Emergencia = 1      
		Cross Apply App.tblConfiguracionesGenerales cg      
	where --EM.IDEmpleado between @IDEmpleadoIni and @IDEmpleadoFIN     and
		cg.IDConfiguracion = 'PathFotos'  and mm.Vigente in (0,1);
	END

   
END
GO
