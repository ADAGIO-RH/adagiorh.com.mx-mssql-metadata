USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Enrutamiento].[spBuscarRutaStepAutorizacion](
	@IDRutaStep int
)
AS
BEGIN
	SELECT 
		a.IDRutaStepsAutorizacion,
		a.IDRutaStep,
		isnull(a.IDPosicion,0) as IDPosicion,
		isnull(a.IDUsuario,0) as IDUsuario,
		Autorizador = CASE WHEN isnull(a.IDPosicion,0) <> 0 THEN 'Posición: '+ISNULL(p.Codigo,'') +' - Plaza: '+isnull(pl.Codigo,'') +' - '+isnull(JSON_VALUE(puesto.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')),'')
								ELSE u.Cuenta +' - '+u.Nombre +' '+u.Apellido
								end,
		TipoAutorizador = CASE WHEN isnull(a.IDPosicion,0) <> 0 THEN 'POSICION'
								ELSE 'USUARIO'
								end

		,a.Orden
	FROM [Enrutamiento].[tblRutaStepsAutorizacion] A with(nolock)
		left join RH.tblCatPosiciones p with(nolock)
			on A.IDPosicion = p.IDPosicion
		left join RH.tblCatPlazas pl
			on pl.IDPlaza = p.IDPlaza
		left join RH.tblCatPuestos puesto
			on pl.IDPuesto = puesto.IDPuesto
		left join Seguridad.tblUsuarios U
			on a.IDUsuario = U.IDUsuario
	WHERE A.IDRutaStep = @IDRutaStep
	ORDER BY A.Orden
END;
GO
