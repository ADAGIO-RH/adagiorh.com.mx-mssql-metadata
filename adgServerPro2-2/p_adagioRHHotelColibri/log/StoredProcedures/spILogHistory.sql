USE [p_adagioRHHotelColibri]
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
CREATE PROCEDURE [log].[spILogHistory]
	-- Add the parameters for the stored procedure here
	@LogLevel		VARCHAR  (20) =  NULL,
    @Mensaje		VARCHAR  (max)=   NULL,
    @IDSource		VARCHAR  (50) =  NULL,
    @IDCategory		VARCHAR  (50) =  NULL,
    @IDAplicacion	VARCHAR (200) = NULL,
    @Url			VARCHAR (MAX) = NULL,
    @HTMLElement	VARCHAR (MAX) = NULL,
    @Keywords		VARCHAR (MAX) = NULL,
    @Data			VARCHAR (MAX) = NULL,
    @IDUsuario		INT				 =NULL,
    @IDReferencia	VARCHAR  (50) =  NULL
AS
BEGIN


 	--INSERT INTO Log.tblLogHistory (LogLevel,Mensaje,IDSource,IDCategory,IDAplicacion,Url,HTMLElement,Keywords,[Data],IDUsuario)
    --VALUES ('2','2','Reports','Excel','ff','ff','ff','ff','ff',1)
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    
    
	INSERT INTO Log.tblLogHistory (LogLevel,Mensaje,IDSource,IDCategory,IDAplicacion,Url,HTMLElement,Keywords,[Data],IDUsuario,IDReferencia)
                        VALUES    (@LogLevel,@Mensaje,@IDSource,@IDCategory,@IDAplicacion,@Url,@HTMLElement,@Keywords,@Data,@IDUsuario,@IDReferencia)

END
GO
