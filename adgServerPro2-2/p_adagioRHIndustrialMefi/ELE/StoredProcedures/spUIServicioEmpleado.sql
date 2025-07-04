USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [ELE].[spUIServicioEmpleado]
(
	@IDServicioEmpleado int = 0
	,@Descripcion NVARCHAR(255)
    ,@Catalogo NVARCHAR(255)
    ,@IDCatalogo int
    ,@IDTipoServicio int 
    ,@IDEmpleado int 
    ,@Fecha datetime
    ,@TiempoFecha time
    ,@TiempoDecimal decimal(10,2)
	,@IDUsuario int	                            
)
AS
BEGIN
			
    DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max);
	
	IF(@IDServicioEmpleado = 0 OR @IDServicioEmpleado Is null)
	BEGIN
					

		INSERT INTO [ELE].[tblServicioEmpleados]
				   (
                    IDEmpleado,
                    IDTipoServicio,
                    Descripcion,
                    Catalogo,
                    IDCatalogo,
                    Fecha,
                    TiempoFecha,                    
                    TiempoDecimal,
                    IDUsuarioRegistro                    
				   )
			 VALUES
			(
				   @IDEmpleado,
                   @IDTipoServicio,
                   @Descripcion,
                   @Catalogo,
                   @IDCatalogo,
                   @Fecha,
                   @TiempoFecha,
                   @TiempoDecimal,
                   @IDUsuario
            )
		  set @IDServicioEmpleado = @@IDENTITY

		select @NewJSON = a.JSON from [ELE].[tblServicioEmpleados] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDServicioEmpleado=@IDServicioEmpleado;

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[ELE].[tblCatTiposServicios]','[ELE].[spIUCatTipoServicio]','INSERT',@NewJSON,''
		
	END
	ELSE
	BEGIN

        select @OldJSON = a.JSON from [ELE].[tblServicioEmpleados] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDServicioEmpleado=@IDServicioEmpleado;

		UPDATE [ELE].[tblServicioEmpleados]
		   SET 
			  [IDEmpleado] = @IDEmpleado,
              [IDTipoServicio] = @IDTipoServicio,
              [Descripcion] = @Descripcion,
              [Catalogo] = @Catalogo,
              [IDCatalogo] = @IDCatalogo,
              [Fecha] = @Fecha,
              [TiempoFecha] = @TiempoFecha,
              [TiempoDecimal] = @TiempoDecimal              
		 WHERE IDServicioEmpleado = @IDServicioEmpleado
		
		select @NewJSON = a.JSON from [ELE].[tblServicioEmpleados] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDServicioEmpleado=@IDServicioEmpleado;

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[ELE].[tblServicioEmpleados]','[ELE].[spIUCatTipoServicio]','UPDATE',@NewJSON,@OldJSON
	END
	 
    exec [ELE].[spBuscarServicioEmpleado] @IDServicioEmpleado=@IDServicioEmpleado,@IDUsuario = @IDUsuario
END
GO
