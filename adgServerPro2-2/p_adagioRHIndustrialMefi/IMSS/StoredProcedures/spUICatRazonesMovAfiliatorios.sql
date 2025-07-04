USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [IMSS].[spUICatRazonesMovAfiliatorios]
(
	     @IDRazonMovimiento int = 0
		,@Codigo varchar(20) = ''
		,@Descripcion varchar(255) 
		,@Alta bit
		,@Baja bit
		,@ReIngreso bit
		,@MovSueldo bit
		,@IDCatTipoRazonMovimiento int = null
		,@IDUsuario int 
)
AS
BEGIN
	SET @Codigo = UPPER(@Codigo)
	SET @Descripcion = UPPER(@Descripcion)

	 DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max);


	IF(@IDRazonMovimiento = 0 OR @IDRazonMovimiento is null)
	BEGIN
		INSERT INTO IMSS.tblCatRazonesMovAfiliatorios(
		 Codigo
		,Descripcion
		,Alta
		,Baja
		,ReIngreso
		,MovSueldo
		,IDCatTipoRazonMovimiento
		)
		Values( @Codigo
				,@Descripcion
				,@Alta
				,@Baja
				,@ReIngreso
				,@MovSueldo
				,CASE WHEN ISNULL(@IDCatTipoRazonMovimiento,0) = 0 THEN NULL ELSE @IDCatTipoRazonMovimiento END
				)

		set @IDRazonMovimiento = @@IDENTITY

		    select @NewJSON = a.JSON from [IMSS].[tblCatRazonesMovAfiliatorios] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDRazonMovimiento = @IDRazonMovimiento

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[IMSS].[tblCatRazonesMovAfiliatorios]','[IMSS].[spUICatRazonesMovAfiliatorios]','INSERT',@NewJSON,''
		


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

	END
	ELSE
	BEGIN

		select @OldJSON = a.JSON from [IMSS].[tblCatRazonesMovAfiliatorios] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDRazonMovimiento = @IDRazonMovimiento

		UPDATE IMSS.tblCatRazonesMovAfiliatorios
			set Codigo = @Codigo
				,Descripcion = @Descripcion
				,Alta = @Alta
				,Baja = @Baja
				,ReIngreso = @ReIngreso
				,MovSueldo = @MovSueldo
				,IDCatTipoRazonMovimiento = CASE WHEN ISNULL(@IDCatTipoRazonMovimiento,0) = 0 THEN NULL ELSE @IDCatTipoRazonMovimiento END
		where IDRazonMovimiento = @IDRazonMovimiento

		   select @NewJSON = a.JSON from [IMSS].[tblCatRazonesMovAfiliatorios] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDRazonMovimiento = @IDRazonMovimiento

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[IMSS].[tblCatRazonesMovAfiliatorios]','[IMSS].[spUICatRazonesMovAfiliatorios]','UPDATE',@NewJSON,@OldJSON

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

	END
END
GO
