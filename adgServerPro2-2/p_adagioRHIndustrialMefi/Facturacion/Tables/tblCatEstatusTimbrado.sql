USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Facturacion].[tblCatEstatusTimbrado](
	[IDEstatusTimbrado] [int] NOT NULL,
	[Descripcion] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_FacturacionTblCatEstatusTimbrado_IDEstatusTimbrado] PRIMARY KEY CLUSTERED 
(
	[IDEstatusTimbrado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
