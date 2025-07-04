USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  proc [Evaluacion360].[spBuscarAvanceObjetivosEmpleados](
	@IDObjetivoEmpleado int = 0
    ,@IDAvanceObjetivoEmpleado int = 0		
	,@IDUsuario int
) as

	SET FMTONLY OFF;  

    DECLARE @IDIdioma varchar(10);
    
    SET @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'es-MX')


    SELECT 
        [AOE].[IDAvanceObjetivoEmpleado]
       ,[AOE].[IDObjetivoEmpleado]
       ,[AOE].[Valor]
       ,[AOE].[Fecha]
       ,[AOE].[FechaCaptura]
       ,[AOE].[Comentario]
       ,[AOE].[IDUsuario]       
       ,[OE].[IDTipoMedicionObjetivo]
       ,JSON_VALUE(CTMO.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as TipoMedicionObjetivo
       ,COALESCE(u.Nombre, '') + ' ' + COALESCE(u.Apellido, '') AS Usuario
       ,Utilerias.GetInfoUsuarioEmpleadoFotoAvatar(0,U.IDUsuario) as UsuarioEmpleadoFotoAvatar
    FROM Evaluacion360.tblAvanceObjetivoEmpleado AOE
    INNER JOIN Evaluacion360.tblObjetivosEmpleados OE
        ON OE.IDObjetivoEmpleado = AOE.IDObjetivoEmpleado
    INNER JOIN Evaluacion360.tblCatTiposMedicionesObjetivos CTMO
        ON CTMO.IDTipoMedicionObjetivo=OE.IDTipoMedicionObjetivo
    INNER JOIN Seguridad.tblUsuarios u WITH (NOLOCK) 
        ON u.IDUsuario = AOE.IDUsuario
    WHERE 
        (AOE.IDObjetivoEmpleado = @IDObjetivoEmpleado OR ISNULL(@IDObjetivoEmpleado, 0) = 0)
        AND 
        (AOE.IDAvanceObjetivoEmpleado = @IDAvanceObjetivoEmpleado OR ISNULL(@IDAvanceObjetivoEmpleado, 0) = 0)
    ORDER BY [AOE].[Fecha] ASC
GO
