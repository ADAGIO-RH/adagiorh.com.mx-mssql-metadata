USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [STPS].[spBorrarSalaCapacitacion]
(
	@IDSalaCapacitacion int,
	@IDUsuario int
)
AS
BEGIN
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[STPS].[spBorrarSalaCapacitacion]',
		@Tabla		varchar(max) = '[STPS].[tblSalasCapacitacion]',
		@Accion		varchar(20)	= 'DELETE',
		@Mensaje	varchar(max),
		@InformacionExtra	varchar(max)
	;

	EXEC STPS.spBuscarSalasCapacitacion @IDSalaCapacitacion = @IDSalaCapacitacion

	BEGIN TRY
		select @OldJSON = a.JSON 
		from (
			SELECT 
				IDSalaCapacitacion
				,Nombre
				,isnull(Ubicacion,'') as Ubicacion
				,isnull(Capacidad,0) as  Capacidad
				,ROW_NUMBER() OVER(Order by IDSalaCapacitacion asc) as ROWNUMBER
			FROM STPS.tblSalasCapacitacion with (nolock)
			where (IDSalaCapacitacion = @IDSalaCapacitacion)
		) b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a

		Delete STPS.tblSalasCapacitacion
		where IDSalaCapacitacion = @IDSalaCapacitacion

		EXEC [Auditoria].[spIAuditoria]
			@IDUsuario		= @IDUsuario
			,@Tabla			= @Tabla
			,@Procedimiento	= @NombreSP
			,@Accion		= @Accion
			,@NewData		= @NewJSON
			,@OldData		= @OldJSON
			,@Mensaje		= @Mensaje
			,@InformacionExtra		= @InformacionExtra
    END TRY  
    BEGIN CATCH  
	   EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
	   return 0;
    END CATCH ;
END
GO
