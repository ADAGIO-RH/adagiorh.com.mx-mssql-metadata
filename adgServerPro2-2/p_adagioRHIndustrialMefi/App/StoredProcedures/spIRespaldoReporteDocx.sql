USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [App].[spIRespaldoReporteDocx]
	-- Add the parameters for the stored procedure here
	@IDUsuario int null,
    @IDReporteBasico int  null,
    @Notas VARCHAR(200),
    @RutaRespaldo VARCHAR(max),
    @NombreArchivo VARCHAR(max)
    

AS
BEGIN

    declare @last_insert_id int = 0;


	INSERT INTO App.tblRespaldoReportesTRDP (IDUsuario,IDReporteBasico,Notas,RutaRespaldo)
    values(@IDUsuario,@IDReporteBasico,@Notas,'');

    SELECT @last_insert_id=@@IDENTITY;
    UPDATE App.tblRespaldoReportesTRDP  set RutaRespaldo = concat(@RutaRespaldo,@last_insert_id,'_',@NombreArchivo) where IDRespaldoReportesTRDP=@last_insert_id; 

    SELECT @last_insert_id [last_id];
    
END
GO
