USE [p_adagioRHCRHIrkon]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Nomina].[tblCatMeses](
	[IDMes] [int] NOT NULL,
	[Descripcion] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Traduccion] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_NominaTblCatMeses_IDMes] PRIMARY KEY CLUSTERED 
(
	[IDMes] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [idx_NominatblCatMeses_Descripcion] ON [Nomina].[tblCatMeses]
(
	[Descripcion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
