USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [IMSS].[spBorrarCatRazonesMovAfiliatorios]
(
	 @IDRazonMovimiento int,
	 @IDUsuario int
)
AS
BEGIN
	begin try
		DECLARE @OldJSON Varchar(Max),
			@NewJSON Varchar(Max);

			select @OldJSON = a.JSON from [IMSS].[tblCatRazonesMovAfiliatorios] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
			WHERE b.IDRazonMovimiento = @IDRazonMovimiento

			EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatRazonesMovAfiliatorios]','[RH].[spBorrarCatRazonesMovAfiliatorios]','DELETE','',@OldJSON
		
		

		SELECT 
			 R.IDRazonMovimiento
			,R.Codigo
			,R.Descripcion
			,R.Alta
			,R.Baja
			,R.ReIngreso
			,R.MovSueldo
			,ISNULL(T.IDCatTipoRazonMovimiento,0) as IDCatTipoRazonMovimiento
			,T.Codigo as CodigoTipoRazonMovimiento
			,T.Descripcion as DescripcionTipoRazonMovimiento
			,ROW_NUMBER()over(ORDER BY IDRazonMovimiento)as ROWNUMBER 
		FROM IMSS.tblCatRazonesMovAfiliatorios R WITH(NOLOCK)
			Left Join Imss.tblCatTiposRazonesMovimientos T With(Nolock)
				on R.IDCatTipoRazonMovimiento = T.IDCatTipoRazonMovimiento
		where R.IDRazonMovimiento = @IDRazonMovimiento

			DELETE IMSS.tblCatRazonesMovAfiliatorios
			where IDRazonMovimiento = @IDRazonMovimiento
	end try
	begin catch
		declare @Error varchar(max) = 'Ocurrio un error al intentar borrar la razón de movimiento afiliatorio'
		raiserror(16,1, @Error)
	end catch
END
GO
