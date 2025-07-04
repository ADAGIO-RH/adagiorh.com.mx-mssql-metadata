USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Enrutamiento].[spBuscarRutaStepsEjecucion](
	@IDRutaStep int
)
AS
BEGIN
    DECLARE
		@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', 1, 'esmx')

	SELECT 
		a.IDRutaStepsEjecucion
	  ,a.IDRutaStep
	  ,isnull(e.IDEmpleado,0) as IDEmpleado
	  ,e.ClaveEmpleado    
	  ,e.NOMBRECOMPLETO  as NombreCompleto  
	  ,ISNULL(p.IDPosicion,0) as IDPosicion    
	  ,Posicion = 'Posición: '+ISNULL(p.Codigo,'') +' - Plaza: '+isnull(pl.Codigo,'') +' - '+isnull(JSON_VALUE(catpue.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')),'')  
	FROM [Enrutamiento].[tblRutaStepsEjecucion] A with(nolock)
		left join RH.tblCatPosiciones p with(nolock)
			on A.IDPosicion = p.IDPosicion
		left join RH.tblCatPlazas pl
			on pl.IDPlaza = p.IDPlaza
		inner join RH.tblCatPuestos catpue with(nolock)
				on catpue.IDPuesto = pl.IDPuesto
		left join RH.tblEmpleadosMaster e
			on p.IDEmpleado = e.IDEmpleado
	WHERE A.IDRutaStep = @IDRutaStep
	
END;
GO
