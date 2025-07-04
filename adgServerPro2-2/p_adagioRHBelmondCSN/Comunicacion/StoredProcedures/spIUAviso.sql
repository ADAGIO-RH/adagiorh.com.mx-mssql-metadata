USE [p_adagioRHBelmondCSN]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Jose Vargas
-- Create date: 2022-01-27
-- Description:	
-- =============================================
CREATE PROCEDURE [Comunicacion].[spIUAviso]
    @IDAviso int ,  
    @IDTipoAviso int ,  
    @Titulo varchar(255),
    @Descripcion varchar(max),
    @DescripcionHTML nvarchar(max),
    @IsGeneral bit, 
    @FechaInicio date,
    @FechaFin date,
    @Ubicacion varchar (255),
    @HoraInicio time,    
    @IDEstatus int ,
    @TopPXToBanner int ,
    @HeightPXToBanner int ,
    @EnviarNotificacion bit,
    @FileJson nvarchar(max),
    @IDUsuario int
AS
BEGIN

    DECLARE @OldJSON Varchar(Max), @NewJSON Varchar(Max)		 
    			
	BEGIN TRY  
		    IF(@IDAviso = 0)  
                BEGIN  	
                        
                        INSERT INTO [Comunicacion].[tblAvisos] (Titulo,IDTipoAviso,Descripcion,DescripcionHTML,IsGeneral,Ubicacion,HoraInicio,FechaInicio,FechaFin,IDEstatus,IDUsuario,FechaCreacion,TopPXToBanner,EnviarNotificacion,HeightPXToBanner,FileJson)
                        values (@Titulo,@IDTipoAviso,@Descripcion,@DescripcionHTML,@IsGeneral,@Ubicacion,@HoraInicio,@FechaInicio,@FechaFin,@IDEstatus,@IDUsuario,getdate(),@TopPXToBanner, @EnviarNotificacion,@HeightPXToBanner, @FileJson) 

                        set @IDAviso=@@IDENTITY

                        select @NewJSON = a.JSON from [Comunicacion].[tblAvisos] b
		                    Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select  b.[IDAviso],
                                                                                            [IDTipoAviso],
                                                                                            [Titulo],
                                                                                            [IsGeneral],
                                                                                            [Ubicacion],
                                                                                            [HoraInicio],
                                                                                            [FechaInicio],
                                                                                            [FechaFin],
                                                                                            [IDEstatus],
                                                                                            [FechaCreacion],
                                                                                            [IDUsuario],
                                                                                            [TopPXToBanner],
                                                                                            [EnviarNotificacion],
                                                                                            [HeightPXToBanner],
                                                                                            [Enviado] For XML Raw)) ) a
		                WHERE b.IDAviso = @IDAviso  
		 
		                EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Comunicacion].[tblAvisos]','[Comunicacion].[spIUAviso]','INSERT',@NewJSON,''                        

                END
            ELSE  
                BEGIN

                	select @OldJSON = a.JSON from [Comunicacion].[tblAvisos] b
                        Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select [IDAviso],
                                                                                    [IDTipoAviso],
                                                                                    [Titulo],
                                                                                    [IsGeneral],
                                                                                    [Ubicacion],
                                                                                    [HoraInicio],
                                                                                    [FechaInicio],
                                                                                    [FechaFin],
                                                                                    [IDEstatus],
                                                                                    [FechaCreacion],
                                                                                    [IDUsuario],
                                                                                    [TopPXToBanner],
                                                                                    [EnviarNotificacion],
                                                                                    [HeightPXToBanner],
                                                                                    [Enviado] For XML Raw)) ) a
                    WHERE b.IDAviso = @IDAviso  

                    UPDATE [Comunicacion].[tblAvisos] set 
                        Titulo=@Titulo,
                        IDTipoAviso=@IDTipoAviso,
                        Descripcion=@Descripcion,
                        DescripcionHTML=@DescripcionHTML,
                        IsGeneral=@IsGeneral ,
                        Ubicacion=@Ubicacion,
                        HoraInicio=@HoraInicio,
                        FechaInicio= @FechaInicio,
                        FechaFin =@FechaFin,
                        TopPXToBanner = @TopPXToBanner,
                        EnviarNotificacion =@EnviarNotificacion,
                        HeightPXToBanner=@HeightPXToBanner,
                        IDEstatus=@IDEstatus,
                        FileJson=@FileJson
                    WHERE IDAviso=@IDAviso

                    
                    select @NewJSON = a.JSON from [Comunicacion].[tblAvisos] b
                        Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select [IDAviso],
                                                                                        [IDTipoAviso],
                                                                                        [Titulo],
                                                                                        [IsGeneral],
                                                                                        [Ubicacion],
                                                                                        [HoraInicio],
                                                                                        [FechaInicio],
                                                                                        [FechaFin],
                                                                                        [IDEstatus],
                                                                                        [FechaCreacion],
                                                                                        [IDUsuario],
                                                                                        [TopPXToBanner],
                                                                                        [EnviarNotificacion],
                                                                                        [HeightPXToBanner],
                                                                                        [Enviado] For XML Raw)) ) a
                    WHERE b.IDAviso = @IDAviso  
                    
                    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Comunicacion].[tblAvisos]','[Comunicacion].[spIUAviso]','UPDATE',@NewJSON,@OldJSON
                
                END

            select @IDAviso [IDAviso]                


            declare @enviado bit 

            select @enviado = Enviado from Comunicacion.tblAvisos where IDAviso=@IDAviso

            IF @EnviarNotificacion = 1 AND @IDEstatus = 2 AND @Enviado = 0
            BEGIN
                EXEC [Comunicacion].[spSchedulerNotificacionAvisos] @IDAviso = @IDAviso, @IDUsuario = 1, @Reenviar = 0, @IDEmpleado = 0;
                UPDATE [Comunicacion].[tblAvisos] SET Enviado = 1 WHERE IDAviso = @IDAviso;
            END
            

	END TRY  
	BEGIN CATCH  
            declare @message varchar(max)
            
            SELECT @message='Ha ocurrido un error al guardar el aviso. ' + ERROR_MESSAGE()
			raiserror( @message  ,16,1);    
		return 0;
	END CATCH ;     

END
GO
