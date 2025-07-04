USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROC [Nomina].[spITablaInversa]
(
	 @IDTablaImpuesto int = 0
	,@IDPeriodicidadPago int
	,@Ejercicio int
	,@IDCalculo int
	,@Descripcion varchar(255)
	,@IDPais int = null
	,@IDUsuario int
) as
BEGIN
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[spITablaInversa]',
		@Tabla		varchar(max) = '[Nomina].[tblTablasImpuestos]',
		@Accion		varchar(20)	= '',
        @IDCalculoInverso int = 6,
        @IDTablaInverso int 
	;

	SET @Descripcion = CONCAT(@Descripcion,' INVERSO ')


IF NOT EXISTS (Select TOP 1 1 FROM Nomina.tblTablasImpuestos WHERE IDPeriodicidadPago = @IDPeriodicidadPago AND IDCalculo = @IDCalculoInverso AND Ejercicio = @Ejercicio AND IDPais = @IDPais)
	BEGIN
		INSERT INTO [Nomina].[tblTablasImpuestos] (IDPeriodicidadPago,Ejercicio,IDCalculo,Descripcion, IDPais)
		SELECT @IDPeriodicidadPago,@Ejercicio,@IDCalculoInverso,@Descripcion, CASE WHEN ISNULL(@IDPais,0) = 0 THEN NULL ELSE @IDPais END

		SELECT @IDTablaInverso=@@IDENTITY


        INSERT INTO Nomina.tblDetalleTablasImpuestos
        Select
        @IDTablaInverso, 
        [LimiteInferior],

        CASE WHEN [LimiteSuperior] IS NULL THEN 999999999.0000 
                                        ELSE LimiteSuperior END 
                                        AS LimiteSuperior,

        CASE WHEN LAG(CuotaFija) OVER (ORDER BY LimiteInferior) IS NULL THEN 0 
                                                                        ELSE LAG(CuotaFija) OVER (ORDER BY LimiteInferior) END 
                                                                        AS CuotaFija,
        [Porcentaje] 
        from 
            ( Select 
            LimiteInferior - CoutaFija as limiteInferior
            ,LimiteSuperior - LEAD(CoutaFija) OVER(ORDER BY CoutaFija) as LimiteSuperior
            ,LimiteSuperior as CuotaFija 
            ,1 - Porcentaje as Porcentaje
            from Nomina.tblDetalleTablasImpuestos 
            where IDTablaImpuesto = @IDTablaImpuesto ) a

		select @NewJSON = a.JSON
			,@Accion = 'INSERT'
		from [Nomina].[tblTablasImpuestos] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDTablaImpuesto = @IDTablaImpuesto

        EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON

    exec [Nomina].[spBuscarTablasImpuesto] @IDTablaImpuesto=@IDTablaImpuesto
    END 
    ELSE
    BEGIN
	RAISERROR('Ya Existe una tabla Inversa de esta Periodicidad, Ejercicio y Pais', 16,1)
    RETURN		
    END;

	
END;
GO
