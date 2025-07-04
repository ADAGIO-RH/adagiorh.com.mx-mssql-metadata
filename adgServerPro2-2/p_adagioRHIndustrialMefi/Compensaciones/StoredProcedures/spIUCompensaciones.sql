USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Compensaciones].[spIUCompensaciones](
	@IDCompensacion int = 0
	,@Descripcion Varchar(250)
	,@IDCatTipoCompensacion int 
	,@IDCliente int null 
	,@IDTipoNomina int null 
	,@IDPeriodo int null 
	,@IDConcepto int null 
	,@IDMatrizIncremento int null 
	,@IDEvaluacion int null
	,@Fecha Date  null
	,@bPorcentaje bit null 
	,@bDiasSueldo bit null 
	,@bMonto bit null 
	,@Porcentaje decimal(18,4) null
	,@DiasSueldo decimal(18,4) null
	,@Monto decimal(18,4) null
	,@IDUsuario int 
)
AS
BEGIN
	SET @Descripcion = UPPER (@Descripcion)

		DECLARE 
		@OldJSON Varchar(Max),
		@NewJSON Varchar(Max)
	;

	IF(ISNULL(@IDCompensacion,0) = 0)
	BEGIN
		INSERT INTO Compensaciones.TblCompensaciones(
			 Descripcion
			,IDCatTipoCompensacion 
			,IDCliente 
			,IDTipoNomina
			,IDPeriodo
			,IDMatrizIncremento 
			,IDEvaluacion 
			,Fecha 
			,bPorcentaje 
			,bDiasSueldo 
			,bMonto 
			,Porcentaje
			,DiasSueldo
			,Monto 
			,IDConcepto
		)
		VALUES(
			 @Descripcion
			,@IDCatTipoCompensacion 
			,@IDCliente 
			,CASE WHEN @IDTipoNomina = 0 THEN NULL ELSE @IDTipoNomina END
			,CASE WHEN @IDPeriodo = 0 THEN  NULL ELSE @IDPeriodo END
			,CASE WHEN @IDMatrizIncremento = 0 THEN NULL ELSE @IDMatrizIncremento END
			,CASE WHEN @IDEvaluacion  = 0 THEN NULL ELSE @IDEvaluacion END
			,@Fecha 
			,CASE WHEN ISNULL(@bPorcentaje,0) = 0 THEN 0 else @bPorcentaje END
			,CASE WHEN ISNULL(@bDiasSueldo,0) = 0 THEN 0 else @bDiasSueldo END 
			,CASE WHEN ISNULL(@bMonto ,0) = 0 THEN 0 else @bMonto  END
			,CASE WHEN ISNULL(@Porcentaje,0) = 0 THEN 0 ELSE @Porcentaje END
			,CASE WHEN ISNULL(@DiasSueldo,0) = 0 THEN 0 ELSE @DiasSueldo END
			,CASE WHEN ISNULL(@Monto 	 ,0) = 0 THEN 0 ELSE @Monto 	 END
			,CASE WHEN ISNULL(@IDConcepto 	 ,0) = 0 THEN null ELSE @IDConcepto 	 END
		)

		set @IDCompensacion = @@identity  

		select @NewJSON = a.JSON from Compensaciones.TblCompensaciones b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDMatrizIncremento = @IDCompensacion

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Compensaciones].[TblCompensaciones]','[Compensaciones].[spIUCompensaciones]','INSERT',@NewJSON,''
	END
	ELSE
	BEGIN

		select @OldJSON = a.JSON from Compensaciones.TblCompensaciones b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDMatrizIncremento = @IDCompensacion


		UPDATE Compensaciones.TblCompensaciones
			set  Descripcion		= @Descripcion
			,IDCatTipoCompensacion 	= @IDCatTipoCompensacion 
			,IDCliente 				= @IDCliente 
			,IDTipoNomina			= CASE WHEN @IDTipoNomina = 0 THEN NULL ELSE @IDTipoNomina END
			,IDPeriodo				= CASE WHEN @IDPeriodo = 0 THEN  NULL ELSE @IDPeriodo END
			,IDMatrizIncremento 	= CASE WHEN @IDMatrizIncremento = 0 THEN NULL ELSE @IDMatrizIncremento END
			,IDEvaluacion 			= CASE WHEN @IDEvaluacion  = 0 THEN NULL ELSE @IDEvaluacion END
			,Fecha 					= @Fecha 
			,bPorcentaje 			= CASE WHEN ISNULL(@bPorcentaje,0) = 0 THEN 0 else @bPorcentaje END
			,bDiasSueldo 			= CASE WHEN ISNULL(@bDiasSueldo,0) = 0 THEN 0 else @bDiasSueldo END 
			,bMonto 				= CASE WHEN ISNULL(@bMonto ,0) = 0 THEN 0 else @bMonto  END
			,Porcentaje				= CASE WHEN ISNULL(@Porcentaje,0) = 0 THEN 0 ELSE @Porcentaje END
			,DiasSueldo				= CASE WHEN ISNULL(@DiasSueldo,0) = 0 THEN 0 ELSE @DiasSueldo END
			,Monto 					= CASE WHEN ISNULL(@Monto 	 ,0) = 0 THEN 0 ELSE @Monto 	 END
			,IDConcepto				= CASE WHEN ISNULL(@IDConcepto 	 ,0) = 0 THEN null ELSE @IDConcepto 	 END
		WHERE IDCompensacion = @IDCompensacion

		select @NewJSON = a.JSON from Compensaciones.TblCompensaciones b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDMatrizIncremento = @IDCompensacion

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Compensaciones].[TblCompensaciones]','[Compensaciones].[spIUCompensaciones]','UPDATE',@NewJSON,@OldJSON
	END
	
	EXEC [Compensaciones].[spBuscarCompensaciones] @IDCompensacion = @IDCompensacion
	,@IDUsuario = @IDUsuario 

END
GO
