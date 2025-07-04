USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Crear/Actualizar Pasos de las Rutas
** Autor			: JOSE ROMAN
** Email			: jroman@adagio.com.mx
** FechaCreacion	: 2022-02-08
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE PROCEDURE [Enrutamiento].[spUIRutaStep]
(
	@IDRutaStep int = 0,
	@IDCatRuta int,
	@IDCatTipoStep int,
	@Orden int ,
	@IDUsuario int
)
AS
BEGIN
	DECLARE 
	 @RecalcularOrdenStep int = 0

	if ((@Orden is null) or (@Orden = 0))
    begin
	   select @Orden=isnull(Max(isnull(Orden,0))+1,1) from Enrutamiento.tblRutaSteps With(NOLOCK) WHERE IDRutaStep = @IDRutaStep and IDCatRuta = @IDCatRuta
    end else
	  set @RecalcularOrdenStep = 1;

	IF(ISNULL(@IDRutaStep,0) = 0)
	BEGIN
		INSERT INTO Enrutamiento.tblRutaSteps(IDCatRuta,IDCatTipoStep,Orden)
		VALUES(@IDCatRuta,@IDCatTipoStep,@Orden)
		SET @IDRutaStep = @@IDENTITY
	END
	ELSE
	BEGIN
		UPDATE Enrutamiento.tblRutaSteps
			SET IDCatTipoStep = @IDCatTipoStep
		WHERE IDRutaStep = @IDRutaStep
	END


	   exec [Enrutamiento].[spActualizarOrdenStep] 
	   @IDRutaStep =@IDRutaStep 
	   ,@IDCatRuta=@IDCatRuta
	   ,@OldIndex = 0  
	   ,@NewIndex = @Orden
	   ,@IDUsuario=@IDUsuario
    

END;
GO
