USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [App].[tblPreferencias](
	[IDPreferencia] [int] IDENTITY(1,1) NOT NULL,
	[Fecha] [datetime] NULL,
 CONSTRAINT [Pk_tblPreferencia_IDPreferencia] PRIMARY KEY CLUSTERED 
(
	[IDPreferencia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [App].[tblPreferencias] ADD  CONSTRAINT [D_tblPreferencias_Fecha]  DEFAULT (getdate()) FOR [Fecha]
GO
