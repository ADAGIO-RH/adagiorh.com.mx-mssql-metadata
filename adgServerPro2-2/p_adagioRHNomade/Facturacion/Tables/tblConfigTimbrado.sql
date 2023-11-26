USE [p_adagioRHNomade]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Facturacion].[tblConfigTimbrado](
	[IDConfigTimbrado] [int] NOT NULL,
	[Nodo] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Campo] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Value] [bit] NULL,
	[Padre] [int] NULL,
 CONSTRAINT [PK_FacturacionTblConfigTimbrado_IDConfigTimbrado] PRIMARY KEY CLUSTERED 
(
	[IDConfigTimbrado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Facturacion].[tblConfigTimbrado] ADD  DEFAULT ((0)) FOR [Padre]
GO
