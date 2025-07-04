USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spIUCatUbicaciones](
    @IDUbicacion int=0
    ,@Nombre varchar(50)
    ,@Latitud float	 null
	,@Longitud float null
	,@Activo bit = 0
    ,@IDUsuario int  
)
AS
BEGIN
    DECLARE 
		@OldJSON Varchar(Max),
		@NewJSON Varchar(Max)
	;

    if(@IDUbicacion =0 or @IDUbicacion is null)
    begin
		IF EXISTS(Select Top 1 1 from RH.[tblCatUbicaciones] where Nombre = @Nombre)  
		BEGIN  
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'  
			RETURN 0;  
		END  
        INSERT INTO [RH].[tblCatUbicaciones](  
                    [Nombre]  			
                    ,[Latitud]
                    ,[Longitud]
                    ,[Activo]
            )  
                VALUES (  
                    UPPER(@Nombre)
                    ,@Latitud
                    ,@Longitud
                    ,ISNULL(@Activo,0)
            )  
		SET @IDUbicacion = @@IDENTITY
    END
    ELSE
    BEGIN
        UPDATE [RH].[tblCatUbicaciones] SET
                    [Nombre]  = UPPER(@Nombre) 			
                    ,[Latitud] =@Latitud
                    ,[Longitud] =@Longitud
                    ,[Activo] =ISNULL(@Activo,0)
        WHERE [IDUbicacion] =@IDUbicacion

    END
    EXEC [RH].[spBuscarCatUbicaciones] @IDUbicacion=@IDUbicacion, @IDUsuario=@IDUsuario
END;
GO
