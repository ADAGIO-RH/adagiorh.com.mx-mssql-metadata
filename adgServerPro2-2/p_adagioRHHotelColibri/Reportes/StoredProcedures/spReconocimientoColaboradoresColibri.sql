USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [Reportes].[spReconocimientoColaboradoresColibri](
	 @CursoCapacitacion   varchar(max) = ''
	,@Empleados  varchar(max) = ''
	,@FechaIni Date
	,@IDUsuario int
)
AS
BEGIN
	SET FMTONLY OFF 
	SET LANGUAGE Spanish; 
	  
if object_id('tempdb..#tempData') is not null        
    drop table #tempData  
  

	SELECT CC.Nombre AS [CURSO]
		,@FechaIni as [FECHA]
		,PCC.FechaIni as [FECHA CURSO]
		,PCC.Duracion as [HORAS]
		,M.NOMBRECOMPLETO as [NOMBRE]
		, ROW_NUMBER()OVER(PARTITION BY M.NOMBRECOMPLETO, CC.Nombre ORDER BY PCC.FechaIni DESC ) RN
		into #tempData
	from [STPS].[tblCursosCapacitacion] CC WITH(NOLOCK)
		inner join [STPS].[tblProgramacionCursosCapacitacion] PCC  WITH(NOLOCK)
			on CC.IDCursoCapacitacion = PCC.IDCursoCapacitacion
		inner join [STPS].[tblProgramacionCursosCapacitacionEmpleados] PCCE  WITH(NOLOCK)
			on PCCE.IDProgramacionCursoCapacitacion = PCC.IDProgramacionCursoCapacitacion
		INNER JOIN [STPS].[tblEstatusCursosEmpleados] ECE  WITH(NOLOCK)
			on ECE.IDEstatusCursoEmpleados = PCCE.IDEstatusCursoEmpleados
			and ECE.Descripcion = 'APROBADO'
		INNER JOIN RH.tblEmpleadosMaster M  WITH(NOLOCK)
			on M.IDEmpleado = PCCE.IDEmpleado
	WHERE CC.IDCursoCapacitacion = CAST(@CursoCapacitacion as Int)
	AND PCCE.IDEmpleado in (SELECT ITEM FROM app.Split(@Empleados,','))

	SELECT CURSO
		,FECHA = [Utilerias].[fnDateToStringByFormat](Fecha,'FL','Spanish')
		,[FECHA CURSO] = [Utilerias].[fnDateToStringByFormat]([FECHA CURSO],'FL','Spanish')
		,[HORAS]
		,[NOMBRE]
	FROM #tempData 
	WHERE RN = 1
	ORDER BY NOMBRE ASC

END
GO
