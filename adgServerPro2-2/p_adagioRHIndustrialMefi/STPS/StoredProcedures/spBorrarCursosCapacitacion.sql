USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [STPS].[spBorrarCursosCapacitacion]
(
	@IDCursoCapacitacion int,
	@IDUsuario int
)
AS
BEGIN
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[STPS].[spBorrarCursosCapacitacion]',
		@Tabla		varchar(max) = '[STPS].[tblCursosCapacitacion]',
		@Accion		varchar(20)	= 'DELETE',
		@Mensaje	varchar(max),
		@InformacionExtra	varchar(max)
	;

	EXEC STPS.spBuscarCursosCapacitacion @IDCursoCapacitacion = @IDCursoCapacitacion
	
	BEGIN TRY  
		select @OldJSON = a.JSON 
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
				ROW_NUMBER()OVER(ORDER BY CC.IDCursoCapacitacion ASC) as ROWNUMBER
			FROM STPS.tblCursosCapacitacion CC with (nolock)
				left join STPS.tblCatTematicas T with (nolock)
					on CC.IDAreaTematica = T.IDTematica
				Left join STPS.tblCatCapacitaciones CP with (nolock)
					on CP.IDCapacitaciones = CC.IDCapacitaciones
			WHERE (CC.IDCursoCapacitacion = @IDCursoCapacitacion)
		) b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a

		Delete STPS.tblCursosCapacitacion
		where IDCursoCapacitacion = @IDCursoCapacitacion

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
END;
GO
