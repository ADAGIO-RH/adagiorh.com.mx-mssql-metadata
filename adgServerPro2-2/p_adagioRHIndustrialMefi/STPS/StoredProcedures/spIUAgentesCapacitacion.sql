USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [STPS].[spIUAgentesCapacitacion](
	@IDAgenteCapacitacion int = 0,
	@Codigo varchar(20) ,
	@IDTipoAgente int,
	@Nombre Varchar(50),
	@Apellidos Varchar(50),
	@RFC Varchar(13),
	@RegistroSTPS Varchar(20),
	@Contacto Varchar(255),
	@IDUsuario int
)
AS
BEGIN
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[STPS].[spIUAgentesCapacitacion]',
		@Tabla		varchar(max) = '[STPS].[tblAgentesCapacitacion]',
		@Accion		varchar(20)	= '',
		@Mensaje	varchar(max),
		@InformacionExtra	varchar(max)
	;

	select @Codigo			= UPPER(@Codigo)
			,@Nombre		= UPPER(@Nombre)
			,@Apellidos		= UPPER(@Apellidos)
			,@RFC			= UPPER(@RFC)
			,@RegistroSTPS	= UPPER(@RegistroSTPS)
			,@Contacto		= UPPER(@Contacto)


	IF(isnull(@Codigo,'') = '')
	BEGIN
		RAISERROR('El Código del Agente es un campo requerido.',16,1);
		RETURN;
	END
	IF(isnull(@Nombre,'') = '')
	BEGIN
		RAISERROR('El Nombre del Agente es un campo requerido.',16,1);
		RETURN;
	END
	IF(isnull(@IDTipoAgente,0) = 0)
	BEGIN
		RAISERROR('El Tipo del Agente es un campo requerido.',16,1);
		RETURN;
	END

	IF(isnull(@IDAgenteCapacitacion,0) = 0)
	BEGIN
	   IF EXISTS(Select Top 1 1 from STPS.tblAgentesCapacitacion where Codigo = @Codigo)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
			RETURN 0;
		END

		Insert into STPS.tblAgentesCapacitacion(Codigo,IDTipoAgente,Nombre,Apellidos,RFC,RegistroSTPS,Contacto)
		Values(@Codigo,@IDTipoAgente,@Nombre,@Apellidos,@RFC,@RegistroSTPS,@Contacto)

		set @IDAgenteCapacitacion = @@IDENTITY

		select @NewJSON = a.JSON
			,@Accion = 'INSERT'
		from (
			SELECT A.IDAgenteCapacitacion,    
				ISNULL(UPPER(A.Codigo),'') as Codigo,    
				ISNULL(A.IDTipoAgente,0) as IDTipoAgente,    
				ISNULL(UPPER(TA.Descripcion),'') as TipoAgente,    
				ISNULL(UPPER(A.Nombre),'') as Nombre,    
				ISNULL(UPPER(A.Apellidos),'') as Apellidos,    
				ISNULL(UPPER(A.RFC),'') as RFC,    
				ISNULL(UPPER(A.RegistroSTPS),'') as RegistroSTPS,    
				ISNULL(UPPER(A.Contacto),'') as Contacto,    
				UPPER(COALESCE(A.RFC,'')+' - '+COALESCE(A.Nombre,'')+' '+COALESCE(A.Apellidos,'')) AS AgenteCapacitacionFull ,    
				ROW_NUMBER()OVER(ORDER BY A.IDAgenteCapacitacion) as ROWNUMBER    
			FROM STPS.tblAgentesCapacitacion A with (nolock)    
				inner join STPS.tblCatTiposAgentes TA with (nolock)   
					on TA.IDTipoAgente = A.IDTipoAgente    
			WHERE (A.IDAgenteCapacitacion = @IDAgenteCapacitacion)
		) b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
	END
	ELSE
	BEGIN
		IF EXISTS(Select Top 1 1 from STPS.tblAgentesCapacitacion where Codigo = @Codigo and IDAgenteCapacitacion <> @IDAgenteCapacitacion)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
			RETURN 0;
		END

		select @OldJSON = a.JSON
			,@Accion = 'UPDATE'
		from (
			SELECT A.IDAgenteCapacitacion,    
				ISNULL(UPPER(A.Codigo),'') as Codigo,    
				ISNULL(A.IDTipoAgente,0) as IDTipoAgente,    
				ISNULL(UPPER(TA.Descripcion),'') as TipoAgente,    
				ISNULL(UPPER(A.Nombre),'') as Nombre,    
				ISNULL(UPPER(A.Apellidos),'') as Apellidos,    
				ISNULL(UPPER(A.RFC),'') as RFC,    
				ISNULL(UPPER(A.RegistroSTPS),'') as RegistroSTPS,    
				ISNULL(UPPER(A.Contacto),'') as Contacto,    
				UPPER(COALESCE(A.RFC,'')+' - '+COALESCE(A.Nombre,'')+' '+COALESCE(A.Apellidos,'')) AS AgenteCapacitacionFull ,    
				ROW_NUMBER()OVER(ORDER BY A.IDAgenteCapacitacion) as ROWNUMBER    
			FROM STPS.tblAgentesCapacitacion A with (nolock)    
				inner join STPS.tblCatTiposAgentes TA with (nolock)   
					on TA.IDTipoAgente = A.IDTipoAgente    
			WHERE (A.IDAgenteCapacitacion = @IDAgenteCapacitacion)
		) b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a

		UPDATE STPS.tblAgentesCapacitacion
			set Codigo = @Codigo,
				IDTipoAgente = @IDTipoAgente,
				Nombre = @Nombre,
				Apellidos = @Apellidos,
				RFC = @RFC,
				RegistroSTPS = @RegistroSTPS,
				Contacto = @Contacto
		where IDAgenteCapacitacion = @IDAgenteCapacitacion

		select @NewJSON = a.JSON
		from (
			SELECT A.IDAgenteCapacitacion,    
				ISNULL(UPPER(A.Codigo),'') as Codigo,    
				ISNULL(A.IDTipoAgente,0) as IDTipoAgente,    
				ISNULL(UPPER(TA.Descripcion),'') as TipoAgente,    
				ISNULL(UPPER(A.Nombre),'') as Nombre,    
				ISNULL(UPPER(A.Apellidos),'') as Apellidos,    
				ISNULL(UPPER(A.RFC),'') as RFC,    
				ISNULL(UPPER(A.RegistroSTPS),'') as RegistroSTPS,    
				ISNULL(UPPER(A.Contacto),'') as Contacto,    
				UPPER(COALESCE(A.RFC,'')+' - '+COALESCE(A.Nombre,'')+' '+COALESCE(A.Apellidos,'')) AS AgenteCapacitacionFull ,    
				ROW_NUMBER()OVER(ORDER BY A.IDAgenteCapacitacion) as ROWNUMBER    
			FROM STPS.tblAgentesCapacitacion A with (nolock)    
				inner join STPS.tblCatTiposAgentes TA with (nolock)   
					on TA.IDTipoAgente = A.IDTipoAgente    
			WHERE (A.IDAgenteCapacitacion = @IDAgenteCapacitacion)
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

	Exec STPS.spBuscarAgentesCapacitacion @IDAgenteCapacitacion = @IDAgenteCapacitacion

END;
GO
