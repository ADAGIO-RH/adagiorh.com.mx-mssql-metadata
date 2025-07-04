USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   procedure [Reportes].[spBuscarContratosEmpleadoExcel] (
	@dtFiltros [Nomina].[dtFiltrosRH] Readonly,
	@IDUsuario int
)
AS
BEGIN
	
	DECLARE  
		@IDIdioma Varchar(5)        
	   ,@IdiomaSQL varchar(100) = null
	   ,@ClaveEmpleadoInicial varchar(255)
	;   

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'es-MX')    
        
	select @IdiomaSQL = [SQL]        
	from app.tblIdiomas with (nolock)        
	where IDIdioma = @IDIdioma        
        
	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)        
	begin        
		set @IdiomaSQL = 'Spanish' ;        
	end        
          
	SET LANGUAGE @IdiomaSQL;   

	select @ClaveEmpleadoInicial = CASE WHEN ISNULL(Value,'') = '' THEN '0' ELSE  Value END
	from @dtFiltros where Catalogo = 'ClaveEmpleadoInicial'

	Select     
		--CE.IDContratoEmpleado,    
		--CE.IDEmpleado,    
		--isnull(CE.IDTipoContrato,0) as IDTipoContrato,    
		E.ClaveEmpleado as [CLAVE EMPLEADO],
		E.NOMBRECOMPLETO as [COLABORADOR],
		E.Departamento as [DEPARTAMENTO],
		E.Sucursal as [SUCURSAL],
		E.Puesto as [PUESTO],
		case when cast(isnull(d.EsContrato,0) as bit) = 1 then 'CONTRATO' else 'DOCUMENTO' end as [TIPO],
		TC.Codigo as [CÓDIGO TIPO CONTRATO],    
		TC.Descripcion as [TIPO DE CONTRATO],
		--isnull(CE.IDTipoTrabajador,0) as IDTipoTrabajador,     
		isnull(tt.Descripcion,'') as [TIPO TRABAJADOR],     
		--isnull(CE.IDDocumento,0) as IDDocumento,    
		D.Descripcion as [DOCUMENTO], 
		FORMAT(CE.FechaIni,'dd/MM/yyyy') as [FECHA INICIO],    
		FORMAT(CE.FechaFin,'dd/MM/yyyy') as [FECHA FIN],
		isnull(ce.Duracion,0) as [DURACIÓN],    
		--ISNULL(ce.IDTipoDocumento,0) as IDTipoDocumento ,    
		td.Descripcion as [TIPO DOCUMENTO],  
		ISNULL(CE.CalificacionEvaluacion, 0.00) AS [CALIFICACIÓN EVALUACIÓN] 
	from RH.tblContratoEmpleado CE    
		join RH.tblEmpleadosMaster E on E.IDEmpleado = CE.IDEmpleado
		join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfeu on dfeu.IDEmpleado = E.IDEmpleado and dfeu.IDUsuario = @IDUsuario
		LEft join Sat.tblCatTiposContrato TC on CE.IDTipoContrato = TC.IDTipoContrato    
		LEft join RH.tblCatDocumentos D on CE.IDDocumento = D.IDDocumento    
		LEft join RH.tblCatTipoDocumento td on td.IDTipoDocumento = ce.IDTipoDocumento    
		left join IMSS.tblCatTipoTrabajador tt on tt.IDTipoTrabajador = ce.IDTipoTrabajador
	WHERE E.ClaveEmpleado = @ClaveEmpleadoInicial
	ORDER BY isnull(d.EsContrato,0) desc, CE.FechaIni Desc 
END
GO
