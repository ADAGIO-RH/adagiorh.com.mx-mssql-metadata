USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [App].[spIEmailEvent]    
    @IDEnviarNotificacionA VARCHAR(100),
    @IDNotifiacion VARCHAR(100),
    -- @OrganizacionId VARCHAR(100),
    @Subdomain VARCHAR(100),
    @Email VARCHAR(255),
    @Event VARCHAR(50),
    @IP VARCHAR(50),
    @SgContentType VARCHAR(50),
    @SgEventId VARCHAR(100),
    @SgMachineOpen BIT,
    @SgMessageId VARCHAR(255),
    @SgTemplateId VARCHAR(100),
    @SgTemplateName VARCHAR(255),
    @IDReferencia int,
    @TipoReferencia  VARCHAR(255),
    @Timestamp BIGINT,
    @TransactionId VARCHAR(100),
    @UserAgent VARCHAR(500),
    @IDUsuario  VARCHAR(500)=null

AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE 
        @ErrorMessage NVARCHAR(4000),
        @ErrorSeverity INT,
        @ErrorState INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO [App].[tblEmailEvents] (
             IDEnviarNotificacionA, IDNotifiacion, 
            Subdomain, Email, [Event], IP, SgContentType, SgEventId,
            SgMachineOpen, SgMessageId, SgTemplateId, SgTemplateName,
            [Timestamp], TransactionId, UserAgent ,IDReferencia,TipoReferencia,IDUsuario
        )
        VALUES (
             @IDEnviarNotificacionA, @IDNotifiacion,
            @Subdomain, @Email, @Event, @IP, @SgContentType, @SgEventId,
            @SgMachineOpen, @SgMessageId, @SgTemplateId, @SgTemplateName,
            @Timestamp, @TransactionId, @UserAgent,@IDReferencia, 
            case when  isnull(@TipoReferencia,'')='' then null else  @TipoReferencia end,@IDUsuario
        );  
        UPDATE [App].[tblEmailEvents] SET CurrentEvent=@Event WHERE SgMessageId=@SgMessageId
        SELECT * FROM [App].[tblEmailEvents] 
        WHERE SgEventId = @SgEventId;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO
