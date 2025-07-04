USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [Reportes].[spReporteBasicoObjetivosKPISDetalle](
	
	 @IDEmpleado int
    ,@IDCicloMedicionObjetivo int
	,@IDUsuario int

) as
	SET FMTONLY OFF;  

    
	
    DECLARE 
    @IDIdioma varchar(20)    
    
    select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')


	select 
		 oe.IDObjetivoEmpleado
        ,oe.Nombre
		,oe.Descripcion as DescripcionObjetivo
		,oe.IDTipoMedicionObjetivo 
		,oe.IDEmpleado
		,oe.Objetivo
		,oe.Actual
		,oe.Peso
		,oe.PorcentajeAlcanzado
		,oe.IDEstatusObjetivoEmpleado
		,oe.IDUsuarioCreo
        ,convert(varchar,oe.UltimaActualizacion, 103) as UltimaActualizacion
		,oe.FechaHoraReg
        ,CicloMedicion.Nombre as CicloMedicion
        ,JSON_VALUE(eo.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as EstatusObjetivoEmpleado
	from Evaluacion360.tblObjetivosEmpleados oe
		INNER JOIN Evaluacion360.tblCatEstatusObjetivosEmpleado eo
            on eo.IDEstatusObjetivoEmpleado = oe.IDEstatusObjetivoEmpleado
        INNER JOIN Evaluacion360.tblCatCiclosMedicionObjetivos CicloMedicion
            on CicloMedicion.IDCicloMedicionObjetivo=oe.IDCicloMedicionObjetivo    
	where (oe.IDCicloMedicionObjetivo = @IDCicloMedicionObjetivo or isnull(@IDCicloMedicionObjetivo, 0) = 0) AND oe.IDEmpleado=@IDEmpleado
GO
