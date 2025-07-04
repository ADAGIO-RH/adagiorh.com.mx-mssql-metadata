USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [App].[tblAdgFiltros](
	[IDAdgFiltro] [int] IDENTITY(1,1) NOT NULL,
	[Show] [bit] NOT NULL,
	[Autobind] [bit] NOT NULL,
	[LabelText] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[NombreParametro] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsRequired] [bit] NOT NULL,
	[NombreVarJS] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[MsjError] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[VisibleAutoBind] [bit] NOT NULL,
	[VisibleLabelText] [bit] NOT NULL,
	[IDTipoComponente] [int] NULL,
	[Orden] [int] NULL,
 CONSTRAINT [Pk_ApptblAdgFiltros_IDAdgFiltros] PRIMARY KEY CLUSTERED 
(
	[IDAdgFiltro] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [App].[tblAdgFiltros] ADD  DEFAULT ((1)) FOR [IsRequired]
GO
ALTER TABLE [App].[tblAdgFiltros] ADD  DEFAULT ('') FOR [NombreVarJS]
GO
ALTER TABLE [App].[tblAdgFiltros] ADD  DEFAULT ('') FOR [MsjError]
GO
ALTER TABLE [App].[tblAdgFiltros] ADD  DEFAULT ((0)) FOR [VisibleAutoBind]
GO
ALTER TABLE [App].[tblAdgFiltros] ADD  DEFAULT ((0)) FOR [VisibleLabelText]
GO
