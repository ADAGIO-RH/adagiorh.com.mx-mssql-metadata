USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [STPS].[spIUCursosCapacitacion]
(
	@IDCursoCapacitacion int = 0,
	@Codigo Varchar(20),
	@Nombre Varchar(255),
	@IDAreaTematica int,
	@IDCapacitaciones int,
	@Color Varchar(20),
	@IDCurso int,
	@IDUsuario int
)
AS
BEGIN
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[STPS].[spIUCursosCapacitacion]',
		@Tabla		varchar(max) = '[STPS].[tblCursosCapacitacion]',
		@Accion		varchar(20)	= '',
		@Mensaje	varchar(max),
		@InformacionExtra	varchar(max)
	;

	SET @Codigo = UPPER(@Codigo)
	SET @Nombre = UPPER(@Nombre)

	IF(isnull(@Codigo,'') = '')
	BEGIN
		RAISERROR('El Código del Curso es un campo requerido.',16,1);
		RETURN;
	END
	IF(isnull(@Nombre,'') = '')
	BEGIN
		RAISERROR('El Nombre del Curso es un campo requerido.',16,1);
		RETURN;
	END

	IF(ISNULL(@IDCursoCapacitacion,0) = 0)
	BEGIN
		INSERT INTO STPS.tblCursosCapacitacion(Codigo,Nombre,IDAreaTematica,IDCapacitaciones,Color, IDCurso)
		VALUES(@Codigo,@Nombre,@IDAreaTematica,@IDCapacitaciones,@Color, @IDCurso)

		SET @IDCursoCapacitacion = @@IDENTITY

		select @NewJSON = a.JSON
			,@Accion = 'INSERT'
		from (
			SELECT CC.IDCursoCapacitacion,
			   UPPER(CC.Codigo) as Codigo,
			   UPPER(CC.Nombre) as Nombre,
			   ISNULL(CC.IDAreaTematica, 0) as IDAreaTematica,
			   UPPER(T.Codigo) as CodigoAreaTematica,
			   UPPER(T.Descripcion) as AreaTematica,
			   ISNULL(CC.IDCapacitaciones,0) as IDCapacitaciones,
			   UPPER(CP.Codigo) as CodigoCapacitaciones,
			   UPPER(CP.Descripcion) as Capacitaciones,
			   CC.Color,
			   CC.IDCurso,
			   ROW_NUMBER()OVER(ORDER BY CC.IDCursoCapacitacion ASC) as ROWNUMBER
			FROM STPS.tblCursosCapacitacion CC
				left join STPS.tblCatTematicas T
					on CC.IDAreaTematica = T.IDTematica
				Left join STPS.tblCatCapacitaciones CP
					on CP.IDCapacitaciones = CC.IDCapacitaciones
			WHERE (CC.IDCursoCapacitacion = @IDCursoCapacitacion)
		) b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
	END
	ELSE
	BEGIN
		select @OldJSON = a.JSON
			,@Accion = 'UPDATE'
		from (
			SELECT CC.IDCursoCapacitacion,
			   UPPER(CC.Codigo) as Codigo,
			   UPPER(CC.Nombre) as Nombre,
			   ISNULL(CC.IDAreaTematica, 0) as IDAreaTematica,
			   UPPER(T.Codigo) as CodigoAreaTematica,
			   UPPER(T.Descripcion) as AreaTematica,
			   ISNULL(CC.IDCapacitaciones,0) as IDCapacitaciones,
			   UPPER(CP.Codigo) as CodigoCapacitaciones,
			   UPPER(CP.Descripcion) as Capacitaciones,
			   CC.Color,
			   CC.IDCurso,
			   ROW_NUMBER()OVER(ORDER BY CC.IDCursoCapacitacion ASC) as ROWNUMBER
			FROM STPS.tblCursosCapacitacion CC
				left join STPS.tblCatTematicas T
					on CC.IDAreaTematica = T.IDTematica
				Left join STPS.tblCatCapacitaciones CP
					on CP.IDCapacitaciones = CC.IDCapacitaciones
			WHERE (CC.IDCursoCapacitacion = @IDCursoCapacitacion)
		) b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a

		UPDATE STPS.tblCursosCapacitacion
			set Codigo = @Codigo,
				Nombre = @Nombre,
				IDAreaTematica =  @IDAreaTematica,
				IDCapacitaciones = @IDCapacitaciones,
				Color = @Color,
				IDCurso = @IDCurso
		WHERE IDCursoCapacitacion = @IDCursoCapacitacion 

		select @NewJSON = a.JSON
		from (
			SELECT CC.IDCursoCapacitacion,
			   UPPER(CC.Codigo) as Codigo,
			   UPPER(CC.Nombre) as Nombre,
			   ISNULL(CC.IDAreaTematica, 0) as IDAreaTematica,
			   UPPER(T.Codigo) as CodigoAreaTematica,
			   UPPER(T.Descripcion) as AreaTematica,
			   ISNULL(CC.IDCapacitaciones,0) as IDCapacitaciones,
			   UPPER(CP.Codigo) as CodigoCapacitaciones,
			   UPPER(CP.Descripcion) as Capacitaciones,
			   CC.Color,
			   CC.IDCurso,
			   ROW_NUMBER()OVER(ORDER BY CC.IDCursoCapacitacion ASC) as ROWNUMBER
			FROM STPS.tblCursosCapacitacion CC
				left join STPS.tblCatTematicas T
					on CC.IDAreaTematica = T.IDTematica
				Left join STPS.tblCatCapacitaciones CP
					on CP.IDCapacitaciones = CC.IDCapacitaciones
			WHERE (CC.IDCursoCapacitacion = @IDCursoCapacitacion)
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

	EXEC STPS.spBuscarCursosCapacitacion @IDCursoCapacitacion = @IDCursoCapacitacion

END;
GO
