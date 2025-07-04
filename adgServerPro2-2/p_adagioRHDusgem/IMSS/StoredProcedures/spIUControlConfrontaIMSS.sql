USE [p_adagioRHDusgem]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: CREATE/UPDATE lista de Controles de Confronta IMSS
** Autor			: JOSE ROMAN
** Email			: jroman@adagio.com.mx
** FechaCreacion	: 2025-02-07
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE   PROCEDURE [IMSS].[spIUControlConfrontaIMSS](
	@IDControlConfrontaIMSS int =null,
	@IDRegPatronal int,
	@Ejercicio int,
	@IDMes  int = null,
	@IDBimestre  int = null,
	@EMA bit = null,
	@EBA bit = null,
	@IDUsuario int 
)
AS
BEGIN
	
	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

	IF(@IDControlConfrontaIMSS = 0 OR @IDControlConfrontaIMSS Is null)
	BEGIN
		INSERT INTO [IMSS].[tblControlConfrontaIMSS]
				   (
					 [IDRegPatronal]
					,[Ejercicio]
					,[IDMes]
					,[IDBimestre]
					,[EMA]
					,[EBA]
                    ,[FechaHoraRegistro]
                    ,[IDUsuario]
				   )
			 VALUES
				   (
				     @IDRegPatronal
					,@Ejercicio
					,CASE WHEN ISNULL(@IDMes,0) = 0 THEN NULL ELSE @IDMes END
					,CASE WHEN ISNULL(@IDBimestre,0) = 0 THEN NULL ELSE @IDBimestre END
					,ISNULL(@EMA,0)
					,ISNULL(@EBA,0)
                    ,GETDATE()
                    ,@IDUsuario
				   )

		Set @IDControlConfrontaIMSS = @@IDENTITY
		
		select @NewJSON = (SELECT *
                            FROM  [IMSS].[tblControlConfrontaIMSS]
                            WHERE IDControlConfrontaIMSS = @IDControlConfrontaIMSS FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[IMSS].[tblControlConfrontaIMSS]','[IMSS].[spIUControlConfrontaIMSS]','INSERT',@NewJSON,''

	END
	ELSE
	BEGIN
		select @OldJSON = (SELECT *
                            FROM  [IMSS].[tblControlConfrontaIMSS]
                            WHERE IDControlConfrontaIMSS = @IDControlConfrontaIMSS FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

		UPDATE [IMSS].[tblControlConfrontaIMSS]
		   SET  [IDRegPatronal] = @IDRegPatronal
				,[Ejercicio]	= @Ejercicio
				,[IDMes]	    = CASE WHEN ISNULL(@IDMes,0) = 0 THEN NULL ELSE @IDMes END
				,[IDBimestre]   = CASE WHEN ISNULL(@IDBimestre,0) = 0 THEN NULL ELSE @IDBimestre END
				,[EMA]		    = ISNULL(@EMA,0)
				,[EBA]		    = ISNULL(@EBA,0)
                
		 WHERE IDControlConfrontaIMSS = @IDControlConfrontaIMSS

		select @NewJSON = (SELECT *
                            FROM  [IMSS].[tblControlConfrontaIMSS]
                            WHERE IDControlConfrontaIMSS = @IDControlConfrontaIMSS FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[IMSS].[tblControlConfrontaIMSS]','[IMSS].[spIUControlConfrontaIMSS]','UPDATE',@NewJSON,@OldJSON
	END

	 EXEC [IMSS].[spBuscarControlConfrontaIMSS] @IDControlConfrontaIMSS = @IDControlConfrontaIMSS, @IDUsuario = @IDUsuario

END
GO
