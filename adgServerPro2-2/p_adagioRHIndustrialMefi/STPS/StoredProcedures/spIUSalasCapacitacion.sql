USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [STPS].[spIUSalasCapacitacion]
(
	@IDSalaCapacitacion int = 0,
	@Nombre Varchar(50),
	@Ubicacion varchar(255),
	@Capacidad int,
	@IDUsuario int
)
AS
BEGIN
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[STPS].[spIUSalasCapacitacion]',
		@Tabla		varchar(max) = '[STPS].[tblSalasCapacitacion]',
		@Accion		varchar(20)	= '',
		@Mensaje	varchar(max),
		@InformacionExtra	varchar(max)
	;

	set @Nombre = UPPER(@Nombre)
	set @Ubicacion = UPPER(@Ubicacion)

	IF(isnull(@Nombre,'') = '')
	BEGIN
		RAISERROR('El Nombre del Agente es un campo requerido.',16,1);
		RETURN;
	END

	IF(ISNULL(@IDSalaCapacitacion,0) = 0)
	BEGIN
		IF EXISTS(Select Top 1 1 from STPS.tblSalasCapacitacion where Nombre = @Nombre)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
			RETURN 0;
		END

		INSERT INTO STPS.tblSalasCapacitacion(Nombre,Ubicacion,Capacidad)
		VALUES(@Nombre,@Ubicacion,@Capacidad)
		
		set @IDSalaCapacitacion = @@IDENTITY

		select @NewJSON = a.JSON
			,@Accion = 'INSERT'
		from (
			SELECT 
				IDSalaCapacitacion
				,Nombre
				,isnull(Ubicacion,'') as Ubicacion
				,isnull(Capacidad,0) as  Capacidad
				,ROW_NUMBER() OVER(Order by IDSalaCapacitacion asc) as ROWNUMBER
			FROM STPS.tblSalasCapacitacion
			where (IDSalaCapacitacion = @IDSalaCapacitacion)
		) b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
	END
	ELSE
	BEGIN
		IF EXISTS(Select Top 1 1 from STPS.tblSalasCapacitacion where Nombre = @Nombre and IDSalaCapacitacion <> @IDSalaCapacitacion)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
			RETURN 0;
		END

		select @OldJSON = a.JSON
			,@Accion = 'UPDATE'
		from (
			SELECT 
				IDSalaCapacitacion
				,Nombre
				,isnull(Ubicacion,'') as Ubicacion
				,isnull(Capacidad,0) as  Capacidad
				,ROW_NUMBER() OVER(Order by IDSalaCapacitacion asc) as ROWNUMBER
			FROM STPS.tblSalasCapacitacion
			where (IDSalaCapacitacion = @IDSalaCapacitacion)
		) b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a

		UPDATE STPS.tblSalasCapacitacion
			set Nombre = @Nombre,
				Ubicacion = @Ubicacion,
				Capacidad = @Capacidad
		WHERE IDSalaCapacitacion = @IDSalaCapacitacion

		select @NewJSON = a.JSON
		from (
			SELECT 
				IDSalaCapacitacion
				,Nombre
				,isnull(Ubicacion,'') as Ubicacion
				,isnull(Capacidad,0) as  Capacidad
				,ROW_NUMBER() OVER(Order by IDSalaCapacitacion asc) as ROWNUMBER
			FROM STPS.tblSalasCapacitacion
			where (IDSalaCapacitacion = @IDSalaCapacitacion)
		) b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
	END

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON
		,@Mensaje		= @Mensaje
		,@InformacionExtra		= @InformacionExtra

	EXEC STPS.spBuscarSalasCapacitacion @IDSalaCapacitacion = @IDSalaCapacitacion

END
GO
