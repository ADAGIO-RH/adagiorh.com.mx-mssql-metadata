USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [Reportes].[spReporteBoletosComidasDetalle] (
	@Fecha date, 
	@IDEmpleado int, 
	@IDUsuario int
)
AS
BEGIN
	DECLARE  
		@IDIdioma Varchar(5)        
		,@IdiomaSQL varchar(100) = null  
		,@Fechas [App].[dtFechasFull]  
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'es-MX')       
        
	select @IdiomaSQL = [SQL]        
	from App.tblIdiomas        
	where IDIdioma = @IDIdioma        
        
	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)        
	begin        
		set @IdiomaSQL = 'Spanish' ;        
	end        
          
	SET LANGUAGE @IdiomaSQL;   

	insert @Fechas      
	exec app.spListaFechas @FechaIni = @Fecha , @FechaFin = @Fecha     

	select 
		M.IDEmpleado
		,CASE 
			When Fecha.DiaSemana = 1 Then 'DOMINGO'
			When Fecha.DiaSemana = 2 Then 'LUNES'
			When Fecha.DiaSemana = 3 Then 'MARTES'
			When Fecha.DiaSemana = 4 Then 'MIERCOLES'
			When Fecha.DiaSemana = 5 Then 'JUEVES'
			When Fecha.DiaSemana = 6 Then 'VIERNES'
			When Fecha.DiaSemana = 7 Then 'SABADO'
		END AS [DiaSemanaLetra]
		,M.ClaveEmpleado
		,M.NOMBRECOMPLETO
		,M.Puesto
		,Fecha.Fecha 
	from @Fechas Fecha
		cross join RH.tblEmpleadosMaster M
		join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe on m.IDEmpleado = dfe.IDEmpleado and dfe.IDUsuario = @IDUsuario
	where  Fecha.DiaSemana in (2,3,4,5,6) and M.Vigente = 1 and M.IDEmpleado = @IDEmpleado
	order by M.ClaveEmpleado,Fecha.Fecha 
END
GO
