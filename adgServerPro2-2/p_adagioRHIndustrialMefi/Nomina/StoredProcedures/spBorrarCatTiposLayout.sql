USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spBorrarCatTiposLayout]
(
	@IDTipoLayout int,
	@IDUsuario int
)
AS
BEGIN
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[spBorrarCatTiposLayout]',
		@Tabla		varchar(max) = '[Nomina].[tblCatTiposLayout]',
		@Accion		varchar(20)	= 'DELETE'
	

	SELECT
		IDTipoLayout
		,TipoLayout
		,ISNULL(TL.IDBanco,0) as IDBanco
		,B.Descripcion as Banco
		,ISNULL(TL.IDConcepto,0) AS IDConcepto
		,C.Descripcion as Concepto
		,ROW_NUMBER()over(order by IDTipoLayout asc) as ROWNUMBER
	FROM Nomina.tblCatTiposLayout TL with (nolock)
		Left Join Sat.tblCatBancos B with (nolock)
			on TL.IDBanco = B.IDBanco
		LEFT JOIN Nomina.tblCatConceptos C with (nolock)
			on C.IDConcepto = TL.IDConcepto
	WHERE (IDTipoLayout = @IDTipoLayout)  

	select @OldJSON = a.JSON 
	from (
		SELECT
			IDTipoLayout
			,TipoLayout
			,ISNULL(TL.IDBanco,0) as IDBanco
			,B.Descripcion as Banco
			,ISNULL(TL.IDConcepto,0) AS IDConcepto
			,C.Descripcion as Concepto
			,ROW_NUMBER()over(order by IDTipoLayout asc) as ROWNUMBER
		FROM Nomina.tblCatTiposLayout TL with (nolock)
			Left Join Sat.tblCatBancos B with (nolock)
				on TL.IDBanco = B.IDBanco
			LEFT JOIN Nomina.tblCatConceptos C with (nolock)
				on C.IDConcepto = TL.IDConcepto
		WHERE (IDTipoLayout = @IDTipoLayout)
	) b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a

	BEGIN TRY  
		DELETE Nomina.tblCatTiposLayout
		WHERE IDTipoLayout = @IDTipoLayout
	END TRY  
    BEGIN CATCH  
	   EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
	   return 0;
    END CATCH ;

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON
END
GO
