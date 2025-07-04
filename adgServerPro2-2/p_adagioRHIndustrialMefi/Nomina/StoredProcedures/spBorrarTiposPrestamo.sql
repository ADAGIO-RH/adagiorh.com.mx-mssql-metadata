USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spBorrarTiposPrestamo]
(
	@IDTipoPrestamo int
	,@IDUsuario int
)
AS
BEGIN
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[]',
		@Tabla		varchar(max) = '[Nomina].[]',
		@Accion		varchar(20)	= 'DELETE'

	SELECT p.IDTipoPrestamo
				,p.Codigo
				,p.Descripcion
				,isnull(p.IDConcepto,0)as IDConcepto
				,c.Codigo +' - '+ c.Descripcion as DescripcionConcepto
	FROM Nomina.tblCatTiposPrestamo p 
		left join Nomina.tblCatConceptos c
			on p.IDConcepto = c.IDConcepto
	WHERE (IDTipoPrestamo = @IDTipoPrestamo)

	select @OldJSON = a.JSON 
	from (
		SELECT p.IDTipoPrestamo
				,p.Codigo
				,p.Descripcion
				,isnull(p.IDConcepto,0)as IDConcepto
				,c.Codigo +' - '+ c.Descripcion as DescripcionConcepto
		FROM Nomina.tblCatTiposPrestamo p 
			left join Nomina.tblCatConceptos c
				on p.IDConcepto = c.IDConcepto
		WHERE (IDTipoPrestamo = @IDTipoPrestamo)
	) b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a

	DELETE Nomina.tblCatTiposPrestamo
	WHERE (IDTipoPrestamo = @IDTipoPrestamo) 

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON 
END
GO
