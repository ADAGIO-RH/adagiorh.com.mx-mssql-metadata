USE [p_adagioRHAlleiva]
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
		)
		Values( @Codigo
				,@Descripcion
				,@Alta
				,@Baja
				,@ReIngreso
				,@MovSueldo)

		set @IDRazonMovimiento = @@IDENTITY

		    select @NewJSON = a.JSON from [IMSS].[tblCatRazonesMovAfiliatorios] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDRazonMovimiento = @IDRazonMovimiento

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[IMSS].[tblCatRazonesMovAfiliatorios]','[IMSS].[spUICatRazonesMovAfiliatorios]','INSERT',@NewJSON,''
		


		SELECT 
			IDRazonMovimiento
			,Codigo
			,Descripcion
			,Alta
			,Baja
			,ReIngreso
			,MovSueldo
			,ROW_NUMBER()over(ORDER BY IDRazonMovimiento)as ROWNUMBER 
		FROM IMSS.tblCatRazonesMovAfiliatorios
		where IDRazonMovimiento = @IDRazonMovimiento

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
		where IDRazonMovimiento = @IDRazonMovimiento

		   select @NewJSON = a.JSON from [IMSS].[tblCatRazonesMovAfiliatorios] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDRazonMovimiento = @IDRazonMovimiento

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[IMSS].[tblCatRazonesMovAfiliatorios]','[IMSS].[spUICatRazonesMovAfiliatorios]','UPDATE',@NewJSON,@OldJSON
		



		SELECT 
			IDRazonMovimiento
			,Codigo
			,Descripcion
			,Alta
			,Baja
			,ReIngreso
			,MovSueldo
			,ROW_NUMBER()over(ORDER BY IDRazonMovimiento)as ROWNUMBER 
		FROM IMSS.tblCatRazonesMovAfiliatorios
		where IDRazonMovimiento = @IDRazonMovimiento

	END
END
GO
