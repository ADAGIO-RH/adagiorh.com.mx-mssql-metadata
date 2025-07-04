USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [Enrutamiento].[fnDescripcionUnidadProceso]
(
	@IDCatTipoProceso int,
	@IDReferencia int
)
RETURNS Varchar(500)
AS
BEGIN
	DECLARE @TipoProceso Varchar(100),
		@Descripcion Varchar(max)
	
	SELECT @TipoProceso = Codigo 
	FROM [Enrutamiento].[tblCatTiposProcesos] WITH(NOLOCK)
	WHERE IDCatTipoProceso = @IDCatTipoProceso
    
	IF(@TipoProceso = 'AUTORIZACION DE PLAZAS Y SOLICITUD DE POSICIONES')
	BEGIN
		SELECT @Descripcion =  COALESCE(P.Codigo,'')+' - '+ COALESCE(pp.Descripcion,'')
		FROM [RH].[tblCatPlazas] P
        INNER join RH.tblCatPuestos pp on pp.IDPuesto=P.IDPuesto
 		WHERE P.IDPlaza = @IDReferencia         
	END
	IF(@TipoProceso = 'AUTORIZACION DE SOLICITUD DE POSICIONES')
	BEGIN

        SELECT @Descripcion = COALESCE( right( '000' + cast( p.IDSolicitudPosiciones AS varchar), 5 ),'') + ' - '+  COALESCE(PL.Codigo,'')+' - '+COALESCE(pp.Descripcion,'')
		    FROM [RH].[tblSolicitudPosiciones] P
			    inner join [RH].[tblCatPlazas] PL
				    on P.IDPlaza = pl.IDPlaza
                INNER join RH.tblCatPuestos pp 
                    on pp.IDPuesto=pl.IDPuesto
 		    WHERE P.IDPlaza = @IDReferencia and p.IsActive=1

	    /*SELECT @Descripcion = COALESCE(P.Codigo,'') + ' - '+  COALESCE(PL.Codigo,'')+' - '+COALESCE(PL.Nombre,'')
		    FROM [RH].[tblCatPosiciones] P
			    inner join [RH].[tblCatPlazas] PL
				    on P.IDPlaza = pl.IDPlaza
 		    WHERE P.IDPosicion = @IDReferencia*/
	END
	IF(@TipoProceso = 'RECLUTAMIENTO CANDIDATO')
	BEGIN
		SELECT @Descripcion = COALESCE(Nombre,'') +' '+ COALESCE(segundoNombre,'')+' '+ COALESCE(Paterno,'') + COALESCE(Materno,'')
		FROM [Reclutamiento].[tblCandidatos] P
 		WHERE P.IDCandidato = @IDReferencia
	END

	RETURN @Descripcion
END
GO
