USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar la configuración predeterminado del Reclutador por Cliente
** Autor			: Aneudy Abreu
** Email			: aabreu@adagio.com.mx
** FechaCreacion	: 2023-09-21
** Paremetros		:              

** DataTypes Relacionados: 

select * from RH.fnBuscaReclutadorDefaultPorCliente (2)
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE   FUNCTION RH.fnBuscaReclutadorDefaultPorCliente 
(	
	-- Add the parameters for the function here
	@IDCliente int
)
RETURNS 
@keysReclutador TABLE 
(
	[Key] varchar(255),
	[Value] varchar(MAX)
)
AS
BEGIN
	DECLARE @jsonSchema NVARCHAR(MAX);

	SELECT @jsonSchema = [Data]
	FROM [RH].[tblCatTipoConfiguracionesCliente]
	WHERE IDTipoConfiguracionCliente = 'ReclutamientoDefault';

	DECLARE @FirstResults TABLE (
		[Key] NVARCHAR(255)
	);

	INSERT INTO @FirstResults ([Key])
	SELECT CONCAT('Reclutador', CASE WHEN [Key] = 'NombreUsuario' THEN 'NombreColaborador' ELSE [Key] END) AS [Key]
	FROM OPENJSON(@jsonSchema, '$.properties');

	DECLARE @SecondResults TABLE (
		[Key] NVARCHAR(255),
		[Value] NVARCHAR(MAX)
	);

	INSERT INTO @SecondResults ([Key], [Value])
	SELECT 
		CONCAT('Reclutador', ISNULL(CASE WHEN B.[Key] = 'NombreUsuario' THEN 'NombreColaborador' ELSE B.[Key] END, '')) AS [Key], 
		B.[Value]
	FROM [RH].[tblConfiguracionesCliente]
	CROSS APPLY OPENJSON([Valor]) B
	WHERE [IDCliente] = @IDCliente
		AND [IDTipoConfiguracionCliente] = 'ReclutamientoDefault';

	insert @keysReclutador
	SELECT 
		CASE WHEN S.[Value] IS NULL THEN F.[Key] ELSE S.[Key] END AS [Key],
		ISNULL(S.[Value], '') AS [Value]
	FROM @FirstResults F
	LEFT JOIN @SecondResults S ON F.[Key] = S.[Key];
	
	RETURN 
END
GO
